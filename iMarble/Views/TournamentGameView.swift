import SwiftUI

struct TournamentGameView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var settings: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject var coordinator: TournamentCoordinator

    var body: some View {
        Group {
            if coordinator.isFinished {
                TournamentSummaryView(coordinator: coordinator) { dismiss() }
            } else {
                ZStack(alignment: .topTrailing) {
                    stageView
                    Text(String(format: localization.string(.tournamentStageLabel), coordinator.stageIndex + 1, TournamentEngine.stageOrder.count))
                        .font(AppTheme.Typography.caption())
                        .foregroundStyle(AppTheme.burntYellow)
                        .padding(.top, 20)
                        .padding(.trailing, 16)
                        .allowsHitTesting(false)
                }
            }
        }
        .id(coordinator.stageIndex)
    }

    @ViewBuilder
    private var stageView: some View {
        switch coordinator.currentStage {
        case .covas(let vm):
            GameView(viewModel: vm)
        case .mound(let vm):
            MoundGameView(viewModel: vm)
        case .chase(let vm):
            ChaseGameView(viewModel: vm)
        }
    }
}

struct TournamentSummaryView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @ObservedObject var coordinator: TournamentCoordinator
    var onExit: () -> Void

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 24) {
                Text(localization.string(.tournamentFinalScore))
                    .font(AppTheme.Typography.headline())
                    .foregroundStyle(AppTheme.burntYellow)

                if let overallWinner = coordinator.overallWinner {
                    Text(String(format: localization.string(.tournamentWinner), overallWinner.name))
                        .font(AppTheme.Typography.title())
                        .foregroundStyle(AppTheme.accentGradient)
                } else {
                    Text(localization.string(.tournamentTie))
                        .font(AppTheme.Typography.title())
                        .foregroundStyle(AppTheme.accentGradient)
                }

                VStack(spacing: 8) {
                    ForEach(coordinator.players.sorted(by: { (coordinator.cumulativeScores[$0.id] ?? 0) > (coordinator.cumulativeScores[$1.id] ?? 0) })) { player in
                        HStack {
                            Text(player.name).foregroundStyle(AppTheme.cream)
                            Spacer()
                            Text("\(coordinator.cumulativeScores[player.id] ?? 0)").foregroundStyle(AppTheme.burntYellow)
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
