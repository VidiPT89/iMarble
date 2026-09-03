import Foundation
import Combine

enum TournamentStage {
    case covas(GameViewModel)
    case mound(MoundGameViewModel)
    case chase(ChaseGameViewModel)

    var viewModel: TournamentStageViewModel {
        switch self {
        case .covas(let vm): return vm
        case .mound(let vm): return vm
        case .chase(let vm): return vm
        }
    }
}

final class TournamentCoordinator: ObservableObject {
    @Published private(set) var stageIndex = 0
    @Published private(set) var currentStage: TournamentStage
    @Published private(set) var cumulativeScores: [UUID: Int] = [:]
    @Published private(set) var isFinished = false

    let players: [Player]
    private var cancellable: AnyCancellable?

    init(players: [Player]) {
        self.players = players
        self.currentStage = TournamentCoordinator.makeStage(mode: TournamentEngine.stageOrder[0], players: players)
        observeCurrentStage()
    }

    private static func makeStage(mode: GameMode, players: [Player]) -> TournamentStage {
        let freshPlayers = players.map { player -> Player in
            var copy = player
            copy.score = 0
            copy.progressIndex = 0
            copy.hasCompletedCourse = false
            copy.capturedMarbleCount = 0
            copy.isEliminated = false
            return copy
        }
        switch mode {
        case .covas:
            return .covas(GameViewModel(players: freshPlayers, rules: .default))
        case .mound:
            return .mound(MoundGameViewModel(players: freshPlayers, rules: .default))
        case .chase:
            return .chase(ChaseGameViewModel(players: freshPlayers, rules: .default))
        case .tournament:
            return .covas(GameViewModel(players: freshPlayers, rules: .default))
        }
    }

    private func observeCurrentStage() {
        cancellable = currentStage.viewModel.phasePublisher
            .filter { $0 == .gameOver }
            .first()
            .sink { [weak self] _ in
                self?.handleStageFinished()
            }
    }

    private func handleStageFinished() {
        let winnerID = matchOriginalPlayer(for: currentStage.viewModel.stageWinner)?.id
        cumulativeScores = TournamentEngine.scoresAfterStageWin(current: cumulativeScores, winnerID: winnerID)

        let nextIndex = stageIndex + 1
        if TournamentEngine.isTournamentOver(completedStages: nextIndex) {
            isFinished = true
            return
        }
        stageIndex = nextIndex
        currentStage = TournamentCoordinator.makeStage(mode: TournamentEngine.stageOrder[nextIndex], players: players)
        observeCurrentStage()
    }

    /// Each stage builds its own copies of `players` (same ids, reset stats),
    /// so map a stage winner back to the tournament's original player by id.
    private func matchOriginalPlayer(for stageWinner: Player?) -> Player? {
        guard let stageWinner else { return nil }
        return players.first { $0.id == stageWinner.id }
    }

    var overallWinner: Player? {
        guard let winnerID = TournamentEngine.overallWinnerID(scores: cumulativeScores) else { return nil }
        return players.first { $0.id == winnerID }
    }
}
