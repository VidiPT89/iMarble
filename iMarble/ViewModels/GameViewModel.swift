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
    @Published var onlinePeerDisconnected: Bool = false
    @Published var canAttack: Bool = false
    @Published var selectedTargetID: UUID?

    let rules: GameRules
    let scene: MarbleScene
    private let engine: GameEngine
    private var turnManager: TurnManager
    private var moveTimeoutWorkItem: DispatchWorkItem?
    private var attackInProgress = false
    private var attackerWasInsideHoleAtLaunch = false
    var hapticsEnabled = true
    var soundEnabled = true
    var localPlayerID: String?
    weak var onlineCoordinator: OnlineGameCoordinator?
    var isApplyingRemoteEvent = false

    private var isLocalPlayersTurn: Bool {
        guard let localPlayerID else { return true }
        return currentPlayer.gamePlayerID == localPlayerID
    }

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

    private var fieldConfigured = false
    private var lastFieldSize: CGSize = .zero

    /// The traditional field is a single line of holes. Landscape lays that
    /// line out left-to-right (matching the physical game); portrait turns
    /// it 90° into a bottom-to-top line so the board actually fills a tall,
    /// narrow screen instead of staying a thin horizontal strip surrounded
    /// by empty space.
    private func isPortraitField(_ size: CGSize) -> Bool {
        size.height > size.width
    }

    private func holePosition(number: Int, size: CGSize) -> CGPoint {
        if isPortraitField(size) {
            let margin = size.height * 0.12
            let spacing = (size.height - margin * 2) / 4
            let y = size.height - margin - spacing * CGFloat(number)
            return CGPoint(x: size.width / 2, y: y)
        } else {
            let margin = size.width * 0.12
            let spacing = (size.width - margin * 2) / 4
            let x = margin + spacing * CGFloat(number)
            return CGPoint(x: x, y: size.height / 2)
        }
    }

    private func papaPosition(size: CGSize) -> CGPoint {
        if isPortraitField(size) {
            return CGPoint(x: size.width * 0.75, y: size.height / 2)
        } else {
            return CGPoint(x: size.width / 2, y: size.height * 0.25)
        }
    }

    private func marbleStartPosition(index: Int, playerCount: Int, size: CGSize) -> CGPoint {
        if isPortraitField(size) {
            let margin = size.height * 0.12
            let spreadX = size.width / 2 + CGFloat(index - playerCount / 2) * 40
            return CGPoint(x: spreadX, y: size.height - margin * 0.5)
        } else {
            let margin = size.width * 0.12
            let spreadY = size.height / 2 + CGFloat(index - playerCount / 2) * 40
            return CGPoint(x: margin * 0.5, y: spreadY)
        }
    }

    func configureField(size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }

        if fieldConfigured {
            layoutField(size: size)
            return
        }
        fieldConfigured = true
        lastFieldSize = size

        for i in 0..<holes.count where holes[i].number > 0 {
            holes[i].position = CodablePoint(holePosition(number: holes[i].number, size: size))
        }
        if let papaIndex = holes.firstIndex(where: { $0.number == 0 }) {
            holes[papaIndex].position = CodablePoint(papaPosition(size: size))
        }
        scene.layoutField(holes: holes, sceneSize: size)

        for (index, player) in players.enumerated() {
            marbles[index].position = CodablePoint(marbleStartPosition(index: index, playerCount: players.count, size: size))
            scene.addMarble(marbles[index], color: SKColor(AppTheme.color(named: player.colorName)))
        }

        phase = .aiming
        currentMessageKey = .aimAtFirstHole
        updateObjectiveHighlight()
        maybeTakeAITurn()
    }

    private func updateObjectiveHighlight() {
        scene.setObjectiveHole(objectiveHoleNumber())
    }

    /// Repositions holes and marbles proportionally to a new available size,
    /// without touching game state (phase, turn, scores). Safe to call on
    /// every size change (rotation, size-class change) mid-game.
    func layoutField(size: CGSize) {
        guard fieldConfigured else {
            configureField(size: size)
            return
        }
        guard size.width > 0, size.height > 0 else { return }
        let oldSize = lastFieldSize
        guard oldSize.width > 0, oldSize.height > 0 else {
            lastFieldSize = size
            return
        }
        guard oldSize != size else { return }

        let scaleX = size.width / oldSize.width
        let scaleY = size.height / oldSize.height
        let oldHolePositions = holes.map { ($0.number, $0.position.cgPoint) }

        for i in holes.indices {
            let newPosition = holes[i].number > 0
                ? holePosition(number: holes[i].number, size: size)
                : papaPosition(size: size)
            holes[i].position = CodablePoint(newPosition)
        }

        for i in marbles.indices where !marbles[i].isCaptured {
            if marbles[i].isInsideHole,
               let nearestOldHole = oldHolePositions.min(by: {
                   $0.1.distance(to: marbles[i].position.cgPoint) < $1.1.distance(to: marbles[i].position.cgPoint)
               }),
               let matchingHole = holes.first(where: { $0.number == nearestOldHole.0 }) {
                marbles[i].position = matchingHole.position
            } else {
                marbles[i].position = CodablePoint(
                    x: marbles[i].position.x * Double(scaleX),
                    y: marbles[i].position.y * Double(scaleY)
                )
            }
        }

        scene.relayoutField(holes: holes, sceneSize: size)
        for marble in marbles where !marble.isCaptured {
            scene.setPosition(marble.id, position: marble.position.cgPoint)
        }

        lastFieldSize = size
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
        guard isLocalPlayersTurn else { return false }
        guard phase == .aiming || phase == .attacking else { return false }
        guard let idx = marbles.firstIndex(where: { $0.id == marbleID }) else { return false }
        guard idx == currentMarbleIndex, !marbles[idx].isCaptured else { return false }
        if phase == .attacking {
            guard selectedTargetID != nil else { return false }
            if rules.attackRequiresHoleLaunch {
                return marbles[idx].isInsideHole
            }
        }
        return true
    }

    func marbleScene(_ scene: MarbleScene, isAttackTarget marbleID: UUID) -> Bool {
        guard !isPaused, isLocalPlayersTurn, phase == .attacking else { return false }
        guard let marble = marbles.first(where: { $0.id == marbleID }) else { return false }
        guard marble.ownerID != currentPlayer.id else { return false }
        return AttackResolver.eligibleTargets(marbles: marbles, attackerOwnerID: currentPlayer.id, rules: rules)
            .contains { $0.id == marbleID }
    }

    func marbleScene(_ scene: MarbleScene, didSelectTarget marbleID: UUID) {
        guard phase == .attacking else { return }
        selectedTargetID = marbleID
        currentMessageKey = .targetSelectedPullToAttack
        if !isApplyingRemoteEvent {
            onlineCoordinator?.broadcastSelectTarget(marbleID: marbles[currentMarbleIndex].id, targetID: marbleID)
        }
    }

    func applyRemoteTargetSelection(_ marbleID: UUID) {
        guard phase == .attacking else { return }
        selectedTargetID = marbleID
        currentMessageKey = .targetSelectedPullToAttack
        scene.clearTargetHighlight()
    }

    func marbleScene(_ scene: MarbleScene, didLaunch marbleID: UUID, dragVector: CGVector) {
        attackInProgress = (phase == .attacking)
        if let idx = marbles.firstIndex(where: { $0.id == marbleID }) {
            attackerWasInsideHoleAtLaunch = marbles[idx].isInsideHole
            marbles[idx].isInsideHole = false
        }
        if soundEnabled { SoundManager.shared.play(.launch) }
        phase = .marbleMoving
        scheduleTimeout()
        if !isApplyingRemoteEvent {
            onlineCoordinator?.broadcastLaunch(marbleID: marbleID, dragVector: dragVector)
        }
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
        if soundEnabled { SoundManager.shared.play(.collision) }
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
        let idx = currentMarbleIndex

        if attackInProgress {
            attackInProgress = false
            phase = .attacking
            marbles[idx].isInsideHole = attackerWasInsideHoleAtLaunch
            let targetID = selectedTargetID ?? pendingAttackTargetID
            selectedTargetID = nil
            pendingAttackTargetID = nil
            scene.clearTargetHighlight()
            if let targetID {
                attemptAttack(targetMarbleID: targetID)
            } else {
                currentMessageKey = .missedAttack
                checkVictoryThenContinue(sameTurn: false)
            }
            return
        }

        phase = .resolvingHole

        if players[idx].hasCompletedCourse == false || rules.courseType == .roundTripWithPapa {
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
                if soundEnabled { SoundManager.shared.play(.holeEntered) }
                currentMessageKey = .enteredHole

                if player.hasCompletedCourse {
                    canAttack = true
                    selectedTargetID = nil
                    currentMessageKey = .chooseTarget
                    phase = .attacking
                } else {
                    phase = .aiming
                    currentMessageKey = .yourTurn
                }
                updateObjectiveHighlight()
                if rules.extraTurnAfterHole {
                    checkVictoryThenContinue(sameTurn: true)
                    return
                }
            } else {
                currentMessageKey = .missedHole
                endTurn()
                return
            }
        }
        checkVictoryThenContinue(sameTurn: false)
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
            if soundEnabled { SoundManager.shared.play(.hit) }
            if rules.captureMarbles {
                currentMessageKey = .keptMarble
                scene.removeMarble(target.id)
            }
            if rules.extraTurnAfterHit {
                checkVictoryThenContinue(sameTurn: true)
                return
            }
        } else {
            currentMessageKey = .missedAttack
        }
        checkVictoryThenContinue(sameTurn: false)
    }

    private func checkVictoryThenContinue(sameTurn: Bool) {
        if let winningPlayer = engine.checkVictory(players: players) {
            winner = winningPlayer
            phase = .gameOver
            currentMessageKey = .gameOver
            if soundEnabled { SoundManager.shared.play(.victory) }
            return
        }
        if sameTurn {
            if canAttack {
                phase = .attacking
                selectedTargetID = nil
                currentMessageKey = .chooseTarget
            } else {
                phase = .aiming
            }
            maybeTakeAITurn()
        } else {
            endTurn()
        }
    }

    private func endTurn() {
        phase = .turnEnded
        canAttack = false
        selectedTargetID = nil
        scene.clearTargetHighlight()
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
        updateObjectiveHighlight()
        maybeTakeAITurn()
    }

    private func maybeTakeAITurn() {
        guard localPlayerID == nil else { return }
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
