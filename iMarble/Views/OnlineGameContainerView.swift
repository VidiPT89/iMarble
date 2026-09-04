import GameKit
import SwiftUI

private struct GameKitMatchmakerView: UIViewControllerRepresentable {
    let onMatchFound: (GKMatch) -> Void
    let onCancelledOrFailed: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onMatchFound: onMatchFound, onCancelledOrFailed: onCancelledOrFailed)
    }

    func makeUIViewController(context: Context) -> GKMatchmakerViewController {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 4
        let controller = GKMatchmakerViewController(matchRequest: request) ?? GKMatchmakerViewController()
        controller.matchmakerDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: GKMatchmakerViewController, context: Context) {}

    final class Coordinator: NSObject, GKMatchmakerViewControllerDelegate {
        let onMatchFound: (GKMatch) -> Void
        let onCancelledOrFailed: () -> Void

        init(onMatchFound: @escaping (GKMatch) -> Void, onCancelledOrFailed: @escaping () -> Void) {
            self.onMatchFound = onMatchFound
            self.onCancelledOrFailed = onCancelledOrFailed
        }

        func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
            onCancelledOrFailed()
        }

        func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
            onCancelledOrFailed()
        }

        func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
            onMatchFound(match)
        }
    }
}

struct OnlineGameContainerView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var settings: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var gameCenter = GameCenterManager.shared

    @State private var coordinator: OnlineGameCoordinator?
    @State private var onlineViewModel: GameViewModel?
    @State private var onlineMoundViewModel: MoundGameViewModel?
    @State private var onlineChaseViewModel: ChaseGameViewModel?
    @State private var showMatchmaker = false
    @State private var showAuthFailure = false
    @State private var selectedMode: GameMode = .covas

    /// Torneio sequences three independent matches and has no single-match
    /// shape this coordinator can represent, so it never reaches the picker.
    private let onlineModes: [GameMode] = [.covas, .mound, .chase]

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            if let onlineViewModel {
                GameView(viewModel: onlineViewModel)
            } else if let onlineMoundViewModel {
                MoundGameView(viewModel: onlineMoundViewModel)
            } else if let onlineChaseViewModel {
                ChaseGameView(viewModel: onlineChaseViewModel)
            } else if coordinator == nil {
                modePicker
            } else {
                VStack(spacing: 20) {
                    ProgressView()
                    Text(localization.string(.onlineWaitingForPlayers))
                        .foregroundStyle(AppTheme.cream)
                    Button(localization.string(.close)) { dismiss() }
                        .buttonStyle(SecondaryButtonStyle())
                }
            }
        }
        .sheet(isPresented: $showMatchmaker) {
            GameKitMatchmakerView(
                onMatchFound: handleMatchFound,
                onCancelledOrFailed: { dismiss() }
            )
        }
        .alert(localization.string(.onlineAuthenticationFailed), isPresented: $showAuthFailure) {
            Button(localization.string(.close)) { dismiss() }
        }
    }

    private var modePicker: some View {
        VStack(spacing: 20) {
            Text(localization.string(.gameModeLabel))
                .font(AppTheme.Typography.headline())
                .foregroundStyle(AppTheme.burntYellow)
            Picker(localization.string(.gameModeLabel), selection: $selectedMode) {
                Text(localization.string(.gameModeCovas)).tag(GameMode.covas)
                Text(localization.string(.gameModeMound)).tag(GameMode.mound)
                Text(localization.string(.gameModeChase)).tag(GameMode.chase)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            Button(localization.string(.play)) { startFlow() }
                .buttonStyle(PrimaryButtonStyle())
            Button(localization.string(.close)) { dismiss() }
                .buttonStyle(SecondaryButtonStyle())
        }
    }

    private func startFlow() {
        guard coordinator == nil else { return }
        if gameCenter.isAuthenticated {
            showMatchmaker = true
        } else {
            gameCenter.authenticate()
            waitForAuthentication()
        }
    }

    private func waitForAuthentication() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch gameCenter.authState {
            case .authenticated:
                showMatchmaker = true
            case .failed:
                showAuthFailure = true
            case .notAuthenticated, .authenticating:
                waitForAuthentication()
            }
        }
    }

    private func handleMatchFound(_ match: GKMatch) {
        showMatchmaker = false
        let newCoordinator = OnlineGameCoordinator(match: match, localPlayer: GKLocalPlayer.local)
        coordinator = newCoordinator

        if newCoordinator.isHost {
            let setup = newCoordinator.hostMatchSetup(mode: selectedMode)
            startGame(players: setup.players, rules: setup.rules, mode: selectedMode, coordinator: newCoordinator)
        } else {
            waitForRemoteSetup(coordinator: newCoordinator)
        }
    }

    private func waitForRemoteSetup(coordinator: OnlineGameCoordinator) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let players = coordinator.setupPlayers, let rules = coordinator.setupRules, let mode = coordinator.setupMode {
                startGame(players: players, rules: rules, mode: mode, coordinator: coordinator)
            } else {
                waitForRemoteSetup(coordinator: coordinator)
            }
        }
    }

    private func startGame(players: [Player], rules: GameRules, mode: GameMode, coordinator: OnlineGameCoordinator) {
        switch mode {
        case .covas:
            let viewModel = GameViewModel(players: players, rules: rules)
            coordinator.attach(to: viewModel)
            onlineViewModel = viewModel
        case .mound:
            let viewModel = MoundGameViewModel(players: players, rules: .default)
            coordinator.attach(to: viewModel)
            onlineMoundViewModel = viewModel
        case .chase:
            let viewModel = ChaseGameViewModel(players: Array(players.prefix(2)), rules: .default)
            coordinator.attach(to: viewModel)
            onlineChaseViewModel = viewModel
        case .tournament:
            break
        }
    }
}
