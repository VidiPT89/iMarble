import Foundation
import Combine
import CoreGraphics
import SpriteKit

private enum ChaseTurnStep {
    case flee
    case chase
}

final class ChaseGameViewModel: ObservableObject, ChaseSceneDelegate {
    @Published var players: [Player]
    @Published var phase: GamePhase = .setup
    @Published var currentMessageKey: LocalizedKey = .chaseFleeAim
    @Published var powerRatio: Double = 0
    @Published var winner: Player?
    @Published var isPaused: Bool = false

    let rules: ChaseRules
    let scene: ChaseScene
    var hapticsEnabled = true
    var soundEnabled = true
    var localPlayerID: String?
    weak var onlineCoordinator: OnlineGameCoordinator?
    var isApplyingRemoteEvent = false

    private var fleeingIndex = 0
    private var chasingIndex = 1
    private var turnStep: ChaseTurnStep = .flee
    private var fleeMarbleID: UUID?
    private var chaseMarbleID: UUID?
    var activeMarbleID: UUID? { turnStep == .flee ? fleeMarbleID : chaseMarbleID }
    private var fieldConfigured = false
    private var launchLine: CGPoint = .zero

    var fleeingPlayer: Player { players[fleeingIndex] }
    var chasingPlayer: Player { players[chasingIndex] }
    var currentPlayer: Player { turnStep == .flee ? fleeingPlayer : chasingPlayer }
    private var isLocalPlayersTurn: Bool {
        guard let localPlayerID else { return true }
        return currentPlayer.gamePlayerID == localPlayerID
    }

    init(players: [Player], rules: ChaseRules) {
        precondition(players.count == 2, "Chase mode is two-player only")
        self.players = players
        self.rules = rules
        self.scene = ChaseScene()
        self.scene.scaleMode = .resizeFill
        scene.chaseDelegate = self
    }

    func configureField(size: CGSize) {
        guard size.width > 0, size.height > 0, !fieldConfigured else { return }
        fieldConfigured = true
        scene.layoutField(sceneSize: size)
        launchLine = CGPoint(x: size.width / 2, y: size.height * 0.12)
        startFleeStep()
    }

    private func startFleeStep() {
        guard !isPaused, phase != .gameOver else { return }
        turnStep = .flee
        phase = .aiming
        currentMessageKey = .chaseFleeAim
        scene.removeAllMarbles()
        chaseMarbleID = nil
        let id = UUID()
        fleeMarbleID = id
        scene.addMarble(id: id, position: launchLine, color: SKColor(AppTheme.color(named: fleeingPlayer.colorName)), readyToLaunch: fleeingPlayer.isHuman)
        maybeTakeAITurn()
    }

    private func startChaseStep() {
        guard !isPaused, phase != .gameOver else { return }
        turnStep = .chase
        phase = .aiming
        currentMessageKey = .chaseChaseAim
        let id = UUID()
        chaseMarbleID = id
        scene.addMarble(id: id, position: launchLine, color: SKColor(AppTheme.color(named: chasingPlayer.colorName)), readyToLaunch: chasingPlayer.isHuman)
        maybeTakeAITurn()
    }

    private func maybeTakeAITurn() {
        guard localPlayerID == nil else { return }
        guard !currentPlayer.isHuman, phase == .aiming else { return }
        let activeID = turnStep == .flee ? fleeMarbleID : chaseMarbleID
        guard let activeID else { return }

        let from = CodablePoint(launchLine)
        let vector: CGVector
        switch turnStep {
        case .flee:
            let target = CodablePoint(x: launchLine.x, y: launchLine.y + Double(scene.size.height) * 0.7)
            vector = AIPlayer.aimVector(from: from, to: target, difficulty: currentPlayer.aiDifficulty)
        case .chase:
            guard let fleeMarbleID, let fleePosition = scene.position(of: fleeMarbleID) else { return }
            vector = AIPlayer.aimVector(from: from, to: CodablePoint(fleePosition), difficulty: currentPlayer.aiDifficulty)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self, self.phase == .aiming else { return }
            self.scene.launch(id: activeID, dragVector: vector)
        }
    }

    func chaseScene(_ scene: ChaseScene, canLaunch id: UUID) -> Bool {
        guard phase == .aiming, currentPlayer.isHuman, isLocalPlayersTurn else { return false }
        let activeID = turnStep == .flee ? fleeMarbleID : chaseMarbleID
        return id == activeID
    }

    func chaseScene(_ scene: ChaseScene, didLaunch id: UUID, dragVector: CGVector) {
        phase = .marbleMoving
        currentMessageKey = .chaseShotInFlight
        if soundEnabled { SoundManager.shared.play(.launch) }
        if !isApplyingRemoteEvent {
            onlineCoordinator?.broadcastChaseLaunch(dragVector: dragVector)
        }
    }

    /// See MoundGameViewModel.applyRemoteLaunch: the active marble's id is
    /// generated fresh and independently on each device every step, so the
    /// remote event carries no id — it targets whichever marble this
    /// device's own turnStep already considers active.
    func applyRemoteLaunch(dragVector: CGVector) {
        let activeID = turnStep == .flee ? fleeMarbleID : chaseMarbleID
        guard let activeID else { return }
        isApplyingRemoteEvent = true
        scene.launch(id: activeID, dragVector: dragVector)
        isApplyingRemoteEvent = false
    }

    func chaseScene(_ scene: ChaseScene, didUpdatePower ratio: Double) {
        powerRatio = ratio
    }

    func chaseSceneShotSettled(_ scene: ChaseScene) {
        guard phase == .marbleMoving else { return }
        switch turnStep {
        case .flee:
            startChaseStep()
        case .chase:
            resolveChaseShot()
        }
    }

    private func resolveChaseShot() {
        guard let fleeMarbleID, let chaseMarbleID,
              let fleePosition = scene.position(of: fleeMarbleID),
              let chasePosition = scene.position(of: chaseMarbleID) else { return }

        let hit = ChaseEngine.isHit(chaserFinalPosition: chasePosition, fleeingPosition: fleePosition, hitRadius: CGFloat(rules.hitRadius))
        if hit {
            players[chasingIndex].score += ScoreRules.hitOpponent
            currentMessageKey = .chaseHit
            if hapticsEnabled { HapticsManager.shared.impact(.heavy) }
            if soundEnabled { SoundManager.shared.play(.hit) }
        } else {
            currentMessageKey = .chaseMissed
        }

        if let winningPlayer = ChaseEngine.winner(players: players, targetPoints: rules.targetPoints) {
            phase = .gameOver
            winner = winningPlayer
            currentMessageKey = .gameOver
            if soundEnabled { SoundManager.shared.play(.victory) }
            ProgressStore.shared.recordMatchResult(humanWon: winningPlayer.isHuman)
            return
        }

        let next = ChaseEngine.nextRoles(hit: hit, fleeingIndex: fleeingIndex, chasingIndex: chasingIndex)
        fleeingIndex = next.fleeing
        chasingIndex = next.chasing
        startFleeStep()
    }

    func pause() { isPaused = true }
    func resume() {
        isPaused = false
        maybeTakeAITurn()
    }
}
