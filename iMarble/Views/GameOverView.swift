import SwiftUI

struct GameOverView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @ObservedObject var viewModel: GameViewModel
    var onExit: () -> Void

    @State private var scale: CGFloat = 0.6

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
                        .scaleEffect(scale)
                        .onAppear {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                scale = 1.0
                            }
                        }
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

                HStack(spacing: 14) {
                    Button(localization.string(.restart)) {
                        viewModel.restart()
                        onExit()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Button(localization.string(.mainMenu)) { onExit() }
                        .buttonStyle(SecondaryButtonStyle())
                }
            }
            .padding()
        }
    }
}
