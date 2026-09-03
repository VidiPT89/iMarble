import XCTest
@testable import iMarble

final class AttackDeadlockTests: XCTestCase {
    func testCompletingCourseWithNoEligibleTargetsDoesNotSoftLockTheGame() {
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: true),
        ]
        var rules = GameRules.default
        rules.victoryMode = .points
        rules.targetScore = 999
        let viewModel = GameViewModel(players: players, rules: rules)
        viewModel.configureField(size: CGSize(width: 400, height: 300))

        // Player A is one hole away from completing the round-trip course.
        viewModel.players[0].progressIndex = rules.holeSequence.count - 1
        // Player B's marble is protected inside a hole, so it can't be
        // attacked right now — no eligible target exists.
        viewModel.marbles[1].isInsideHole = true

        let attackerMarbleID = viewModel.marbles[0].id
        guard let finalHole = viewModel.holes.first(where: { $0.number == rules.holeSequence.last }) else {
            return XCTFail("expected a final hole in the sequence")
        }

        viewModel.phase = .marbleMoving
        viewModel.marbleScene(viewModel.scene, marbleDidStop: attackerMarbleID, at: finalHole.position.cgPoint)

        XCTAssertTrue(viewModel.players[0].hasCompletedCourse)
        XCTAssertNotEqual(viewModel.phase, .attacking, "should not sit in the attacking phase with nothing attackable")
        XCTAssertNotEqual(viewModel.currentPlayer.name, "A", "turn should have passed since there was nothing left to do")
    }

    func testCompletingCourseWithAnEligibleTargetEntersAttackingPhase() {
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: true),
        ]
        var rules = GameRules.default
        rules.victoryMode = .points
        rules.targetScore = 999
        let viewModel = GameViewModel(players: players, rules: rules)
        viewModel.configureField(size: CGSize(width: 400, height: 300))

        viewModel.players[0].progressIndex = rules.holeSequence.count - 1

        let attackerMarbleID = viewModel.marbles[0].id
        guard let finalHole = viewModel.holes.first(where: { $0.number == rules.holeSequence.last }) else {
            return XCTFail("expected a final hole in the sequence")
        }

        viewModel.phase = .marbleMoving
        viewModel.marbleScene(viewModel.scene, marbleDidStop: attackerMarbleID, at: finalHole.position.cgPoint)

        XCTAssertEqual(viewModel.phase, .attacking)
        XCTAssertEqual(viewModel.currentPlayer.name, "A")
    }
}
