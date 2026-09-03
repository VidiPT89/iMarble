import SwiftUI

struct GameView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var settings: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: GameViewModel
    @State private var showQuickRules = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 8) {
                header

                GameBoardView(viewModel: viewModel)
                    .padding(.horizontal, 12)

                footer
            }
            .padding(.vertical, 8)

            VStack {
                GameMessageView(key: viewModel.currentMessageKey)
                    .padding(.top, 60)
                Spacer()
            }

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
            GameOverView(viewModel: viewModel) {
                dismiss()
            }
        }
        .sheet(isPresented: $showQuickRules) {
            RulesView()
        }
        .statusBarHidden()
    }

    private var header: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(viewModel.players) { player in
                        PlayerStatusView(player: player, isActive: player.id == viewModel.currentPlayer.id)
                    }
                }
            }
            Spacer(minLength: 8)
            PowerMeterView(ratio: viewModel.powerRatio)
                .frame(width: 90)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 16)
    }

    private var footer: some View {
        HStack {
            if let objective = viewModel.objectiveHoleNumber() {
                Text(String(format: localization.string(.aimAtHole), objective))
                    .font(AppTheme.Typography.caption())
                    .foregroundStyle(AppTheme.burntYellow)
            }
            Spacer()
            Button(localization.string(.quickRules)) { showQuickRules = true }
                .buttonStyle(SecondaryButtonStyle())
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
                Button(localization.string(.restart)) { viewModel.restart() }
                    .buttonStyle(SecondaryButtonStyle())
                Button(localization.string(.mainMenu)) { dismiss() }
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
}
