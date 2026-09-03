import XCTest
@testable import iMarble

final class TournamentEngineTests: XCTestCase {
    func testStageOrderIsCovasMoundChase() {
        XCTAssertEqual(TournamentEngine.stageOrder, [.covas, .mound, .chase])
    }

    func testScoresAfterStageWinAddsOnePointToWinner() {
        let a = UUID()
        let scores = TournamentEngine.scoresAfterStageWin(current: [:], winnerID: a)
        XCTAssertEqual(scores[a], 1)
    }

    func testScoresAfterStageWinAccumulatesAcrossStages() {
        let a = UUID()
        var scores = TournamentEngine.scoresAfterStageWin(current: [:], winnerID: a)
        scores = TournamentEngine.scoresAfterStageWin(current: scores, winnerID: a)
        XCTAssertEqual(scores[a], 2)
    }

    func testScoresAfterStageWinIgnoresATie() {
        let a = UUID()
        var scores = TournamentEngine.scoresAfterStageWin(current: [:], winnerID: a)
        scores = TournamentEngine.scoresAfterStageWin(current: scores, winnerID: nil)
        XCTAssertEqual(scores[a], 1)
        XCTAssertEqual(scores.count, 1)
    }

    func testIsTournamentOverAfterAllStages() {
        XCTAssertFalse(TournamentEngine.isTournamentOver(completedStages: 2))
        XCTAssertTrue(TournamentEngine.isTournamentOver(completedStages: 3))
    }

    func testOverallWinnerIsHighestScorer() {
        let a = UUID()
        let b = UUID()
        let winner = TournamentEngine.overallWinnerID(scores: [a: 2, b: 1])
        XCTAssertEqual(winner, a)
    }

    func testOverallWinnerIsNilOnTie() {
        let a = UUID()
        let b = UUID()
        XCTAssertNil(TournamentEngine.overallWinnerID(scores: [a: 1, b: 1]))
    }

    func testOverallWinnerIsNilWhenNobodyScored() {
        XCTAssertNil(TournamentEngine.overallWinnerID(scores: [:]))
    }
}
