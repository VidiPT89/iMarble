import SwiftUI

struct ChaseGameView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var settings: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ChaseGameViewModel

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 8) {
                header
                ChaseBoardView(viewModel: viewModel)
                    .padding(.horizontal, 12)
                footer
            }
            .padding(.vertical, 8)

            VStack {
                GameMessageView(key: viewModel.currentMessageKey)
                    .padding(.top, 60)
                Spacer()
            }
            .allowsHitTesting(false)

            if viewModel.isPaused {
                pauseOverlay
            }
        }
        .onAppear {
            viewModel.hapticsEnabled = settings.hapticsEnabled
            viewModel.soundEnabled = settings.soundEnabled
            viewModel.scene.reduceMotion = settings.reduceMotion
        }
        .fullScreenCover(isPresented: Binding(get: { viewModel.phase == .gameOver }, set: { _ in })) {
            ChaseGameOverView(viewModel: viewModel) { dismiss() }
        }
        .statusBarHidden()
    }

    private var header: some View {
        HStack(spacing: 6) {
            ForEach(viewModel.players) { player in
                PlayerStatusView(player: player, isActive: player.id == viewModel.currentPlayer.id)
            }
        }
        .padding(.horizontal, 16)
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button(localization.string(.pause)) { viewModel.pause() }
                .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal, 16)
    }

    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 20) {
                Text(localization.string(.pause))
                    .font(AppTheme.Typography.headline())
                    .foregroundStyle(AppTheme.cream)
                Button(localization.string(.resume)) { viewModel.resume() }
                    .buttonStyle(PrimaryButtonStyle())
                Button(localization.string(.mainMenu)) { dismiss() }
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
}

struct ChaseGameOverView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @ObservedObject var viewModel: ChaseGameViewModel
    var onExit: () -> Void

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 24) {
                Text(localization.string(.gameOver))
                    .font(AppTheme.Typography.headline())
                    .foregroundStyle(AppTheme.burntYellow)

                if let winner = viewModel.winner {
                    Text(String(format: localization.string(.winnerIs), winner.name))
                        .font(AppTheme.Typography.title())
                        .foregroundStyle(AppTheme.accentGradient)
                }

                VStack(spacing: 8) {
                    ForEach(viewModel.players.sorted(by: { $0.score > $1.score })) { player in
                        HStack {
                            Text(player.name).foregroundStyle(AppTheme.cream)
                            Spacer()
                            Text("\(player.score)").foregroundStyle(AppTheme.burntYellow)
                        }
                        .font(AppTheme.Typography.body())
                        .padding(.horizontal, 30)
                    }
                }

                Button(localization.string(.mainMenu)) { onExit() }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
        }
    }
}
