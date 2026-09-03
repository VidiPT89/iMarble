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
    @State private var showMatchmaker = false
    @State private var showAuthFailure = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            if let onlineViewModel {
                GameView(viewModel: onlineViewModel)
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
        .onAppear(perform: startFlow)
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

    private func startFlow() {
        guard coordinator == nil, onlineViewModel == nil else { return }
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
            let setup = newCoordinator.hostMatchSetup()
            startGame(players: setup.players, rules: setup.rules, coordinator: newCoordinator)
        } else {
            waitForRemoteSetup(coordinator: newCoordinator)
        }
    }

    private func waitForRemoteSetup(coordinator: OnlineGameCoordinator) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let players = coordinator.setupPlayers, let rules = coordinator.setupRules {
                startGame(players: players, rules: rules, coordinator: coordinator)
            } else {
                waitForRemoteSetup(coordinator: coordinator)
            }
        }
    }

    private func startGame(players: [Player], rules: GameRules, coordinator: OnlineGameCoordinator) {
        let viewModel = GameViewModel(players: players, rules: rules)
        coordinator.attach(to: viewModel)
        onlineViewModel = viewModel
    }
}
