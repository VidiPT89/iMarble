import Foundation
import Combine
import CoreGraphics
import SpriteKit

final class MoundGameViewModel: ObservableObject, MoundSceneDelegate {
    @Published var players: [Player]
    @Published var pileMarbles: [MoundMarble]
    @Published var phase: GamePhase = .setup
    @Published var currentMessageKey: LocalizedKey = .moundAim
    @Published var powerRatio: Double = 0
    @Published var winner: Player?
    @Published var isPaused: Bool = false

    let rules: MoundRules
    let scene: MoundScene
    private var turnManager: TurnManager
    private var shooterID: UUID?
    private var skipNextTurnPlayerIDs: Set<UUID> = []
    var hapticsEnabled = true
    var soundEnabled = true

    private var currentPlayerIndex: Int { turnManager.activePlayerOrderIndex }
    var currentPlayer: Player { players[currentPlayerIndex] }

    private var fieldConfigured = false
    private var circleCenter: CGPoint = .zero
    private var circleRadius: CGFloat = 0

    init(players: [Player], rules: MoundRules) {
        self.players = players
        self.rules = rules
        self.turnManager = TurnManager(playerCount: players.count)
        self.scene = MoundScene()
        self.scene.scaleMode = .resizeFill

        var marbles: [MoundMarble] = []
        for player in players {
            for _ in 0..<rules.marblesPerPlayer {
                marbles.append(MoundMarble(ownerID: player.id, position: CodablePoint(x: 0, y: 0)))
            }
        }
        self.pileMarbles = marbles
        scene.moundDelegate = self
    }

    func configureField(size: CGSize) {
        guard size.width > 0, size.height > 0, !fieldConfigured else { return }
        fieldConfigured = true

        circleCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        circleRadius = min(size.width, size.height) * 0.28
        scene.layoutField(sceneSize: size, radius: circleRadius)

        for i in pileMarbles.indices {
            let angle = Double.random(in: 0..<(2 * .pi))
            let distance = Double.random(in: 0...(circleRadius * 0.7))
            let position = CGPoint(
                x: circleCenter.x + CGFloat(cos(angle)) * CGFloat(distance),
                y: circleCenter.y + CGFloat(sin(angle)) * CGFloat(distance)
            )
            pileMarbles[i].position = CodablePoint(position)
            let owner = players.first { $0.id == pileMarbles[i].ownerID }!
            scene.addMarble(id: pileMarbles[i].id, position: position, color: SKColor(AppTheme.color(named: owner.colorName)))
        }

        startTurn()
    }

    private func shooterStartPosition(for index: Int) -> CGPoint {
        let angle = Double(index) * (2 * .pi / Double(players.count))
        let distance = Double(circleRadius) * 1.6
        return CGPoint(
            x: circleCenter.x + CGFloat(cos(angle)) * CGFloat(distance),
            y: circleCenter.y + CGFloat(sin(angle)) * CGFloat(distance)
        )
    }

    private func startTurn() {
        guard !isPaused, phase != .gameOver else { return }
        phase = .aiming
        currentMessageKey = .moundAim
        if let shooterID { scene.removeMarble(shooterID) }
        let id = UUID()
        shooterID = id
        scene.addShooter(id: id, position: shooterStartPosition(for: currentPlayerIndex), color: SKColor(AppTheme.color(named: currentPlayer.colorName)))
        maybeTakeAITurn()
    }

    private func maybeTakeAITurn() {
        guard !currentPlayer.isHuman, phase == .aiming, let shooterID else { return }
        guard let target = pileMarbles.filter({ !$0.isCaptured }).min(by: {
            $0.position.distance(to: CodablePoint(shooterStartPosition(for: currentPlayerIndex))) <
            $1.position.distance(to: CodablePoint(shooterStartPosition(for: currentPlayerIndex)))
        }) else { return }
        let from = CodablePoint(shooterStartPosition(for: currentPlayerIndex))
        let vector = AIPlayer.aimVector(from: from, to: target.position, difficulty: currentPlayer.aiDifficulty)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self, self.shooterID == shooterID, self.phase == .aiming else { return }
            self.scene.launchShooter(id: shooterID, dragVector: vector)
        }
    }

    func moundScene(_ scene: MoundScene, canLaunchShooter id: UUID) -> Bool {
        phase == .aiming && currentPlayer.isHuman && id == shooterID
    }

    func moundScene(_ scene: MoundScene, didLaunchShooter id: UUID, dragVector: CGVector) {
        phase = .marbleMoving
        currentMessageKey = .moundShotInFlight
    }

    func moundScene(_ scene: MoundScene, didUpdatePower ratio: Double) {
        powerRatio = ratio
    }

    func moundSceneShotSettled(_ scene: MoundScene) {
        guard phase == .marbleMoving, let shooterID, let shooterPosition = scene.position(of: shooterID) else { return }

        for i in pileMarbles.indices {
            if let p = scene.position(of: pileMarbles[i].id) {
                pileMarbles[i].position = CodablePoint(p)
            }
        }

        let result = MoundEngine.resolveShot(shooterFinalPosition: shooterPosition, pileMarbles: pileMarbles, center: circleCenter, radius: circleRadius)

        if result.burned {
            currentMessageKey = .moundBurned
            if rules.burnLosesShooter {
                skipNextTurnPlayerIDs.insert(currentPlayer.id)
            }
        } else if !result.capturedMarbleIDs.isEmpty {
            for id in result.capturedMarbleIDs {
                guard let idx = pileMarbles.firstIndex(where: { $0.id == id }) else { continue }
                pileMarbles[idx].isCaptured = true
                scene.removeMarble(id)
            }
            if let idx = players.firstIndex(where: { $0.id == currentPlayer.id }) {
                players[idx].capturedMarbleCount += result.capturedMarbleIDs.count
                players[idx].score += result.capturedMarbleIDs.count * ScoreRules.captureMarble
            }
            currentMessageKey = .moundCaptured
        } else {
            currentMessageKey = .moundMissed
        }

        if MoundEngine.isRoundOver(pileMarbles: pileMarbles) {
            phase = .gameOver
            winner = MoundEngine.winner(players: players)
            currentMessageKey = .gameOver
            if let winner { ProgressStore.shared.recordMatchResult(humanWon: winner.isHuman) }
            return
        }

        advanceTurn()
    }

    private func advanceTurn() {
        let activeFlags = players.map { _ in true }
        turnManager.advance(activePlayers: activeFlags)
        if skipNextTurnPlayerIDs.remove(currentPlayer.id) != nil {
            turnManager.advance(activePlayers: activeFlags)
        }
        startTurn()
    }

    func pause() { isPaused = true }
    func resume() {
        isPaused = false
        maybeTakeAITurn()
    }
}
