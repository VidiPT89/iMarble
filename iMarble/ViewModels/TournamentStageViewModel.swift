import Combine

protocol TournamentStageViewModel: AnyObject {
    var phasePublisher: AnyPublisher<GamePhase, Never> { get }
    var stageWinner: Player? { get }
}

extension GameViewModel: TournamentStageViewModel {
    var phasePublisher: AnyPublisher<GamePhase, Never> { $phase.eraseToAnyPublisher() }
    var stageWinner: Player? { winner }
}

extension MoundGameViewModel: TournamentStageViewModel {
    var phasePublisher: AnyPublisher<GamePhase, Never> { $phase.eraseToAnyPublisher() }
    var stageWinner: Player? { winner }
}

extension ChaseGameViewModel: TournamentStageViewModel {
    var phasePublisher: AnyPublisher<GamePhase, Never> { $phase.eraseToAnyPublisher() }
    var stageWinner: Player? { winner }
}
