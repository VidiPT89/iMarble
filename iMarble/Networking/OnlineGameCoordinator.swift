import Combine
import Foundation
import GameKit

final class OnlineGameCoordinator: NSObject, ObservableObject, GKMatchDelegate {
    @Published var setupPlayers: [Player]?
    @Published var setupRules: GameRules?
    @Published var setupMode: GameMode?
    @Published var peerDisconnected = false

    let match: GKMatch
    let localPlayer: GKPlayer
    let isHost: Bool
    let hostPlayerID: String

    private weak var covasViewModel: GameViewModel?
    private weak var moundViewModel: MoundGameViewModel?
    private weak var chaseViewModel: ChaseGameViewModel?

    init(match: GKMatch, localPlayer: GKPlayer) {
        self.match = match
        self.localPlayer = localPlayer
        let allIDs = (match.players.map(\.gamePlayerID) + [localPlayer.gamePlayerID])
        self.hostPlayerID = Self.electHost(playerIDs: allIDs)
        self.isHost = hostPlayerID == localPlayer.gamePlayerID
        super.init()
        match.delegate = self
    }

    static func electHost(playerIDs: [String]) -> String {
        playerIDs.min() ?? ""
    }

    func attach(to viewModel: GameViewModel) {
        covasViewModel = viewModel
        viewModel.localPlayerID = localPlayer.gamePlayerID
        viewModel.onlineCoordinator = self
    }

    func attach(to viewModel: MoundGameViewModel) {
        moundViewModel = viewModel
        viewModel.localPlayerID = localPlayer.gamePlayerID
        viewModel.onlineCoordinator = self
    }

    func attach(to viewModel: ChaseGameViewModel) {
        chaseViewModel = viewModel
        viewModel.localPlayerID = localPlayer.gamePlayerID
        viewModel.onlineCoordinator = self
    }

    /// Torneio is deliberately excluded from online play: it sequences three
    /// independent matches with their own per-stage setup, which does not
    /// fit this coordinator's one-match/one-`GKMatch` lifecycle without a
    /// much larger session-management redesign. `SetupGameView` hides the
    /// online entry point for `.tournament` accordingly.
    func hostMatchSetup(mode: GameMode) -> (players: [Player], rules: GameRules) {
        let allPlayers = ([localPlayer] + match.players)
            .sorted { $0.gamePlayerID < $1.gamePlayerID }
        let palette = AppTheme.playerPalette
        let players = allPlayers.enumerated().map { index, player in
            Player(
                name: player.displayName,
                colorName: palette[index % palette.count],
                isHuman: true,
                gamePlayerID: player.gamePlayerID
            )
        }
        let rules = GameRules.default
        setupPlayers = players
        setupRules = rules
        setupMode = mode
        send(.matchSetup(players: players, rules: rules, mode: mode, hostPlayerID: hostPlayerID))
        return (players, rules)
    }

    func send(_ event: NetworkGameEvent) {
        guard let data = event.encoded() else { return }
        try? match.sendData(toAllPlayers: data, with: .reliable)
    }

    func broadcastLaunch(marbleID: UUID, dragVector: CGVector) {
        send(.launch(marbleID: marbleID, dragVector: NetworkVector(dragVector)))
    }

    func broadcastSelectTarget(marbleID: UUID, targetID: UUID) {
        send(.selectAttackTarget(marbleID: marbleID, targetID: targetID))
    }

    func broadcastMoundLaunch(dragVector: CGVector) {
        send(.moundLaunch(dragVector: NetworkVector(dragVector)))
    }

    func broadcastChaseLaunch(dragVector: CGVector) {
        send(.chaseLaunch(dragVector: NetworkVector(dragVector)))
    }

    private func apply(_ event: NetworkGameEvent) {
        switch event {
        case let .matchSetup(players, rules, mode, _):
            setupPlayers = players
            setupRules = rules
            setupMode = mode
        case let .launch(marbleID, dragVector):
            guard let covasViewModel else { return }
            covasViewModel.isApplyingRemoteEvent = true
            covasViewModel.scene.launch(marbleID: marbleID, dragVector: dragVector.cgVector)
            covasViewModel.isApplyingRemoteEvent = false
        case let .selectAttackTarget(_, targetID):
            guard let covasViewModel else { return }
            covasViewModel.isApplyingRemoteEvent = true
            covasViewModel.applyRemoteTargetSelection(targetID)
            covasViewModel.isApplyingRemoteEvent = false
        case let .moundLaunch(dragVector):
            moundViewModel?.applyRemoteLaunch(dragVector: dragVector.cgVector)
        case let .chaseLaunch(dragVector):
            chaseViewModel?.applyRemoteLaunch(dragVector: dragVector.cgVector)
        case .peerDisconnected:
            peerDisconnected = true
            covasViewModel?.onlinePeerDisconnected = true
            covasViewModel?.pause()
            moundViewModel?.pause()
            chaseViewModel?.pause()
        }
    }

    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        guard let event = NetworkGameEvent.decode(data) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.apply(event)
        }
    }

    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        guard state == .disconnected else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.peerDisconnected = true
            self.covasViewModel?.onlinePeerDisconnected = true
            self.covasViewModel?.pause()
            self.moundViewModel?.pause()
            self.chaseViewModel?.pause()
        }
    }
}
