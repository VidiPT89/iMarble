import Foundation
import Combine
import CoreGraphics
import SpriteKit

final class GameViewModel: ObservableObject, MarbleSceneDelegate {
    @Published var players: [Player]
    @Published var marbles: [Marble]
    @Published var holes: [Hole]
    @Published var phase: GamePhase = .setup
    @Published var currentMessageKey: LocalizedKey = .yourTurn
    @Published var powerRatio: Double = 0
    @Published var winner: Player?
    @Published var isPaused: Bool = false
    @Published var palmoAvailable: Bool = false
    @Published var canAttack: Bool = false

    let rules: GameRules
    let scene: MarbleScene
    private let engine: GameEngine
    private var turnManager: TurnManager
    private var activeMarbleIndexByPlayer: [UUID: Int] = [:]
    private var palmoUsedThisAttempt = false
    private var moveTimeoutWorkItem: DispatchWorkItem?
    var hapticsEnabled = true
    var soundEnabled = true

    init(players: [Player], rules: GameRules) {
        self.players = players
        self.rules = rules
        self.engine = GameEngine(rules: rules)
        self.turnManager = TurnManager(playerCount: players.count)
        self.scene = MarbleScene()
        self.scene.scaleMode = .resizeFill

        var generatedHoles: [Hole] = []
        for number in 1...3 {
            generatedHoles.append(Hole(number: number, position: CodablePoint(x: 0, y: 0), radius: GameRules.holeRadius))
        }
        if rules.courseType == .roundTripWithPapa {
            generatedHoles.append(Hole(number: 0, position: CodablePoint(x: 0, y: 0), radius: GameRules.holeRadius * 0.7))
        }
        self.holes = generatedHoles

        var generatedMarbles: [Marble] = []
        for player in players {
            generatedMarbles.append(Marble(ownerID: player.id, position: CodablePoint(x: 0, y: 0)))
        }
        self.marbles = generatedMarbles

        scene.gameDelegate = self
    }

    func configureField(size: CGSize) {
        let margin: CGFloat = size.width * 0.12
        let spacing = (size.width - margin * 2) / 4
        for i in 0..<holes.count where holes[i].number > 0 {
            let x = margin + spacing * CGFloat(holes[i].number)
            holes[i].position = CodablePoint(x: Double(x), y: Double(size.height / 2))
        }
        if let papaIndex = holes.firstIndex(where: { $0.number == 0 }) {
            holes[papaIndex].position = CodablePoint(x: Double(size.width / 2), y: Double(size.height * 0.25))
        }
        scene.layoutField(holes: holes, sceneSize: size)

        for (index, player) in players.enumerated() {
            let startX = margin * 0.5
            let startY = size.height / 2 + CGFloat(index - players.count / 2) * 40
            marbles[index].position = CodablePoint(x: Double(startX), y: Double(startY))
            scene.addMarble(marbles[index], color: SKColor(AppTheme.color(named: player.colorName)))
        }

        phase = .aiming
        currentMessageKey = .aimAtFirstHole
        maybeTakeAITurn()
    }

    var currentPlayer: Player {
        players[turnManager.activePlayerOrderIndex]
    }

    private var currentMarbleIndex: Int {
        turnManager.activePlayerOrderIndex
    }

    func objectiveHoleNumber() -> Int? {
        HoleResolver.nextTarget(sequence: rules.holeSequence, progressIndex: currentPlayer.progressIndex)
    }

    // MARK: MarbleSceneDelegate

    func marbleScene(_ scene: MarbleScene, canLaunch marbleID: UUID) -> Bool {
        guard !isPaused else { return false }
        guard phase == .aiming || phase == .attacking else { return false }
        guard let idx = marbles.firstIndex(where: { $0.id == marbleID }) else { return false }
        return idx == currentMarbleIndex && !marbles[idx].isCaptured
    }

    func marbleScene(_ scene: MarbleScene, didLaunch marbleID: UUID) {
        phase = .marbleMoving
        scheduleTimeout()
    }

    func marbleScene(_ scene: MarbleScene, didUpdatePower ratio: Double) {
        powerRatio = ratio
    }

    func marbleScene(_ scene: MarbleScene, marbleDidStop marbleID: UUID, at position: CGPoint) {
        guard phase == .marbleMoving, marbleID == marbles[currentMarbleIndex].id else { return }
        moveTimeoutWorkItem?.cancel()
        marbles[currentMarbleIndex].position = CodablePoint(position)
        resolveMove()
    }

    func marbleScene(_ scene: MarbleScene, marblesCollided idA: UUID, idB: UUID) {
        if hapticsEnabled {
            HapticsManager.shared.impact(.light)
        }
    }

    private func scheduleTimeout() {
        moveTimeoutWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.phase == .marbleMoving else { return }
            let idx = self.currentMarbleIndex
            self.marbles[idx].position = CodablePoint(self.scene.convert(.zero, to: self.scene))
            self.resolveMove()
        }
        moveTimeoutWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + GameRules.moveTimeoutSeconds, execute: work)
    }

    private func resolveMove() {
        phase = .resolvingHole
        let idx = currentMarbleIndex

        if phase == .resolvingHole, players[idx].hasCompletedCourse == false || rules.courseType == .roundTripWithPapa {
            var player = players[idx]
            var marble = marbles[idx]
            let entered = engine.processHoleEntry(player: &player, marble: &marble, holes: holes)
            players[idx] = player
            marbles[idx] = marble

            if entered {
                scene.setPosition(marble.id, position: marble.position.cgPoint)
                scene.setProtected(marble.id, protected: marble.isProtected)
                scene.playEntrySplash(at: marble.position.cgPoint)
                if hapticsEnabled { HapticsManager.shared.impact(.medium) }
                currentMessageKey = .enteredHole

                if player.hasCompletedCourse {
                    canAttack = true
                    currentMessageKey = .canAttackNow
                    phase = .attacking
                } else {
                    phase = .aiming
                    currentMessageKey = .yourTurn
                }
                if rules.extraTurnAfterHole {
                    checkVictoryThenContinue(sameTurn: true)
                    return
                }
            } else {
                currentMessageKey = .missedHole
                offerPalmoOrEndTurn()
                return
            }
        }
        checkVictoryThenContinue(sameTurn: false)
    }

    private func offerPalmoOrEndTurn() {
        if rules.allowsPalmo, !palmoUsedThisAttempt {
            palmoAvailable = true
            phase = .choosingPalmo
            currentMessageKey = .youHavePalmo
        } else {
            endTurn()
        }
    }

    func usePalmo(direction: CGVector) {
        guard phase == .choosingPalmo else { return }
        let idx = currentMarbleIndex
        let length = min(sqrt(direction.dx * direction.dx + direction.dy * direction.dy), CGFloat(rules.palmoDistance))
        guard length > 0 else { skipPalmo(); return }
        let normalized = CGVector(dx: direction.dx / length, dy: direction.dy / length)
        var newPosition = marbles[idx].position.cgPoint
        newPosition.x += normalized.dx * length
        newPosition.y += normalized.dy * length
        marbles[idx].position = CodablePoint(newPosition)
        scene.setPosition(marbles[idx].id, position: newPosition)
        palmoUsedThisAttempt = true
        palmoAvailable = false
        phase = .aiming
        currentMessageKey = .pullAndRelease
    }

    func skipPalmo() {
        palmoAvailable = false
        endTurn()
    }

    func attemptAttack(targetMarbleID: UUID) {
        guard phase == .attacking else { return }
        guard let targetIdx = marbles.firstIndex(where: { $0.id == targetMarbleID }) else { return }
        guard let targetOwnerIdx = players.firstIndex(where: { $0.id == marbles[targetIdx].ownerID }) else { return }
        let idx = currentMarbleIndex

        var attacker = players[idx]
        var target = marbles[targetIdx]
        var targetOwner = players[targetOwnerIdx]
        let attackerMarble = marbles[idx]

        let success = engine.processAttack(attacker: &attacker, attackerMarble: attackerMarble, target: &target, targetOwner: &targetOwner)
        players[idx] = attacker
        marbles[targetIdx] = target
        players[targetOwnerIdx] = targetOwner

        if success {
            currentMessageKey = .hitMarble
            scene.pulseHit(at: target.position.cgPoint)
            if hapticsEnabled { HapticsManager.shared.impact(.heavy) }
            if rules.captureMarbles {
                currentMessageKey = .keptMarble
                scene.removeMarble(target.id)
            }
            if rules.extraTurnAfterHit {
                checkVictoryThenContinue(sameTurn: true)
                return
            }
        }
        checkVictoryThenContinue(sameTurn: false)
    }

    private func checkVictoryThenContinue(sameTurn: Bool) {
        if let winningPlayer = engine.checkVictory(players: players) {
            winner = winningPlayer
            phase = .gameOver
            currentMessageKey = .gameOver
            return
        }
        if sameTurn {
            palmoUsedThisAttempt = false
            phase = canAttack ? .attacking : .aiming
            maybeTakeAITurn()
        } else {
            endTurn()
        }
    }

    private func endTurn() {
        phase = .turnEnded
        canAttack = false
        palmoUsedThisAttempt = false
        var activeFlags = players.map { !$0.isEliminated }
        turnManager.advance(activePlayers: activeFlags)
        activeFlags = players.map { !$0.isEliminated }
        if turnManager.remainingActiveCount(activePlayers: activeFlags) <= 1, rules.victoryMode == .classic {
            if let winningPlayer = engine.checkVictory(players: players) {
                winner = winningPlayer
                phase = .gameOver
                currentMessageKey = .gameOver
                return
            }
        }
        phase = .aiming
        currentMessageKey = .yourTurn
        maybeTakeAITurn()
    }

    private func maybeTakeAITurn() {
        guard phase == .aiming || phase == .attacking else { return }
        let player = currentPlayer
        guard !player.isHuman else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            let idx = self.currentMarbleIndex
            let marble = self.marbles[idx]
            let targetHoleNumber = self.objectiveHoleNumber()
            let targetPosition = targetHoleNumber.flatMap { number in self.holes.first(where: { $0.number == number })?.position }
                ?? marble.position

            let opponents = AttackResolver.eligibleTargets(marbles: self.marbles, attackerOwnerID: player.id, rules: self.rules)
            let decision = AIPlayer.decideMove(
                difficulty: player.aiDifficulty,
                marblePosition: marble.position,
                targetPosition: targetPosition,
                opponentMarbles: opponents,
                canAttack: self.phase == .attacking,
                rules: self.rules
            )

            if self.phase == .attacking, let targetID = decision.attackTargetID {
                self.scene.launch(marbleID: marble.id, dragVector: decision.dragVector)
                self.pendingAttackTargetID = targetID
            } else {
                self.pendingAttackTargetID = nil
                self.scene.launch(marbleID: marble.id, dragVector: decision.dragVector)
            }
        }
    }

    private var pendingAttackTargetID: UUID?

    func pause() { isPaused = true }
    func resume() { isPaused = false }

    func restart() {
        turnManager = TurnManager(playerCount: players.count)
        for i in players.indices {
            players[i].score = 0
            players[i].progressIndex = 0
            players[i].isEliminated = false
            players[i].hasCompletedCourse = false
            players[i].capturedMarbleCount = 0
        }
        winner = nil
        phase = .setup
    }
}
