import Combine
import Foundation
import GameKit

final class OnlineGameCoordinator: NSObject, ObservableObject, GKMatchDelegate {
    @Published var setupPlayers: [Player]?
    @Published var setupRules: GameRules?
    @Published var peerDisconnected = false

    let match: GKMatch
    let localPlayer: GKPlayer
    let isHost: Bool
    let hostPlayerID: String

    weak var viewModel: GameViewModel?

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
        self.viewModel = viewModel
        viewModel.localPlayerID = localPlayer.gamePlayerID
        viewModel.onlineCoordinator = self
    }

    func hostMatchSetup() -> (players: [Player], rules: GameRules) {
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
        send(.matchSetup(players: players, rules: rules, hostPlayerID: hostPlayerID))
        return (players, rules)
    }

    func send(_ event: NetworkGameEvent) {
        guard let data = event.encoded() else { return }
        try? match.sendData(toAllPlayers: data, with: .reliable)
    }

    func broadcastLaunch(marbleID: UUID, dragVector: CGVector) {
        send(.launch(marbleID: marbleID, dragVector: NetworkVector(dragVector)))
    }

    func broadcastPalmo(marbleID: UUID, vector: CGVector) {
        send(.palmo(marbleID: marbleID, vector: NetworkVector(vector)))
    }

    func broadcastSkipPalmo(marbleID: UUID) {
        send(.skipPalmo(marbleID: marbleID))
    }

    func broadcastSelectTarget(marbleID: UUID, targetID: UUID) {
        send(.selectAttackTarget(marbleID: marbleID, targetID: targetID))
    }

    private func apply(_ event: NetworkGameEvent) {
        guard let viewModel else { return }
        switch event {
        case let .matchSetup(players, rules, _):
            setupPlayers = players
            setupRules = rules
        case let .launch(marbleID, dragVector):
            viewModel.isApplyingRemoteEvent = true
            viewModel.scene.launch(marbleID: marbleID, dragVector: dragVector.cgVector)
            viewModel.isApplyingRemoteEvent = false
        case let .palmo(_, vector):
            viewModel.isApplyingRemoteEvent = true
            viewModel.usePalmo(direction: vector.cgVector)
            viewModel.isApplyingRemoteEvent = false
        case .skipPalmo:
            viewModel.isApplyingRemoteEvent = true
            viewModel.skipPalmo()
            viewModel.isApplyingRemoteEvent = false
        case let .selectAttackTarget(_, targetID):
            viewModel.isApplyingRemoteEvent = true
            viewModel.applyRemoteTargetSelection(targetID)
            viewModel.isApplyingRemoteEvent = false
        case .peerDisconnected:
            peerDisconnected = true
            viewModel.onlinePeerDisconnected = true
            viewModel.pause()
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
            self.viewModel?.onlinePeerDisconnected = true
            self.viewModel?.pause()
        }
    }
}
