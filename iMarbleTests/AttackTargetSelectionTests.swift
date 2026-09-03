import XCTest
@testable import iMarble

final class AttackTargetSelectionTests: XCTestCase {
    private func makeAttackingViewModel() -> (GameViewModel, UUID, UUID) {
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: true),
        ]
        var rules = GameRules.default
        rules.victoryMode = .points
        rules.targetScore = 999
        let viewModel = GameViewModel(players: players, rules: rules)
        viewModel.configureField(size: CGSize(width: 400, height: 300))

        let attackerID = viewModel.marbles[0].id
        let targetID = viewModel.marbles[1].id

        viewModel.players[0].hasCompletedCourse = true
        viewModel.marbles[0].isInsideHole = true
        viewModel.canAttack = true
        viewModel.phase = .attacking

        return (viewModel, attackerID, targetID)
    }

    func testOpponentMarbleIsEligibleTargetDuringAttackingPhase() {
        let (viewModel, _, targetID) = makeAttackingViewModel()
        let isTarget = viewModel.marbleScene(viewModel.scene, isAttackTarget: targetID)
        XCTAssertTrue(isTarget)
    }

    func testOwnMarbleIsNotAnEligibleTarget() {
        let (viewModel, attackerID, _) = makeAttackingViewModel()
        let isTarget = viewModel.marbleScene(viewModel.scene, isAttackTarget: attackerID)
        XCTAssertFalse(isTarget)
    }

    func testLaunchIsBlockedUntilTargetIsSelected() {
        let (viewModel, attackerID, _) = makeAttackingViewModel()
        XCTAssertFalse(viewModel.marbleScene(viewModel.scene, canLaunch: attackerID))
    }

    func testSelectingTargetEnablesLaunchAndResolvesHitOnStop() {
        let (viewModel, attackerID, targetID) = makeAttackingViewModel()

        viewModel.marbleScene(viewModel.scene, didSelectTarget: targetID)
        XCTAssertEqual(viewModel.selectedTargetID, targetID)
        XCTAssertTrue(viewModel.marbleScene(viewModel.scene, canLaunch: attackerID))

        viewModel.marbleScene(viewModel.scene, didLaunch: attackerID)
        XCTAssertEqual(viewModel.phase, .marbleMoving)

        guard let targetIdx = viewModel.marbles.firstIndex(where: { $0.id == targetID }) else {
            return XCTFail("target marble missing")
        }
        let hitPosition = viewModel.marbles[targetIdx].position.cgPoint
        viewModel.marbleScene(viewModel.scene, marbleDidStop: attackerID, at: hitPosition)

        XCTAssertTrue(viewModel.marbles[targetIdx].isCaptured)
        XCTAssertNil(viewModel.selectedTargetID)
        XCTAssertEqual(viewModel.players[0].capturedMarbleCount, 1)
    }

    func testMissedAttackShowsMissedAttackMessageAndEndsTurn() {
        let (viewModel, attackerID, targetID) = makeAttackingViewModel()
        guard let targetIdx = viewModel.marbles.firstIndex(where: { $0.id == targetID }) else {
            return XCTFail("target marble missing")
        }
        viewModel.marbles[targetIdx].position = CodablePoint(x: 350, y: 250)

        viewModel.marbleScene(viewModel.scene, didSelectTarget: targetID)
        viewModel.marbleScene(viewModel.scene, didLaunch: attackerID)
        viewModel.marbleScene(viewModel.scene, marbleDidStop: attackerID, at: CGPoint(x: 10, y: 10))

        XCTAssertFalse(viewModel.marbles[targetIdx].isCaptured)
        XCTAssertNil(viewModel.selectedTargetID)
        XCTAssertEqual(viewModel.phase, .aiming)
    }
}
