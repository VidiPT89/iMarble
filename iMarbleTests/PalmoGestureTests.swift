import XCTest
@testable import iMarble

final class PalmoGestureTests: XCTestCase {
    private func makeChoosingPalmoViewModel() -> (GameViewModel, UUID) {
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: true),
        ]
        var rules = GameRules.default
        rules.victoryMode = .points
        rules.targetScore = 999
        let viewModel = GameViewModel(players: players, rules: rules)
        viewModel.configureField(size: CGSize(width: 400, height: 300))

        let marbleID = viewModel.marbles[0].id
        viewModel.phase = .choosingPalmo
        viewModel.palmoAvailable = true

        return (viewModel, marbleID)
    }

    func testOnlyCurrentMarbleIsPalmoTargetDuringChoosingPalmo() {
        let (viewModel, marbleID) = makeChoosingPalmoViewModel()
        XCTAssertTrue(viewModel.marbleScene(viewModel.scene, isPalmoTarget: marbleID))

        let otherID = viewModel.marbles[1].id
        XCTAssertFalse(viewModel.marbleScene(viewModel.scene, isPalmoTarget: otherID))
    }

    func testNoMarbleIsPalmoTargetOutsideChoosingPalmoPhase() {
        let (viewModel, marbleID) = makeChoosingPalmoViewModel()
        viewModel.phase = .aiming
        XCTAssertFalse(viewModel.marbleScene(viewModel.scene, isPalmoTarget: marbleID))
    }

    func testPalmoRangeMatchesRules() {
        let (viewModel, marbleID) = makeChoosingPalmoViewModel()
        let range = viewModel.marbleScene(viewModel.scene, palmoRangeFor: marbleID)
        XCTAssertEqual(range, CGFloat(viewModel.rules.palmoDistance))
    }

    func testDraggingPalmoMovesMarbleAndClampsToRange() {
        let (viewModel, marbleID) = makeChoosingPalmoViewModel()
        guard let idx = viewModel.marbles.firstIndex(where: { $0.id == marbleID }) else {
            return XCTFail("marble missing")
        }
        let origin = viewModel.marbles[idx].position.cgPoint
        let farVector = CGVector(dx: viewModel.rules.palmoDistance * 5, dy: 0)

        viewModel.marbleScene(viewModel.scene, didDragPalmo: marbleID, vector: farVector)

        let moved = viewModel.marbles[idx].position.cgPoint
        let distance = sqrt(pow(moved.x - origin.x, 2) + pow(moved.y - origin.y, 2))
        XCTAssertEqual(distance, viewModel.rules.palmoDistance, accuracy: 0.001)
        XCTAssertEqual(viewModel.phase, .aiming)
        XCTAssertFalse(viewModel.palmoAvailable)
    }

    func testZeroLengthDragSkipsThePalmo() {
        let (viewModel, marbleID) = makeChoosingPalmoViewModel()
        viewModel.marbleScene(viewModel.scene, didDragPalmo: marbleID, vector: .zero)
        XCTAssertFalse(viewModel.palmoAvailable)
    }

    func testMissingAHoleDoesNotOfferPalmoUnderAfterEverySuccessPolicy() {
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: true),
        ]
        var rules = GameRules.default
        rules.palmoPolicy = .afterEverySuccess
        let viewModel = GameViewModel(players: players, rules: rules)
        viewModel.configureField(size: CGSize(width: 400, height: 300))

        let marbleID = viewModel.marbles[0].id
        viewModel.phase = .marbleMoving
        let farFromAnyHole = CGPoint(x: -1000, y: -1000)
        viewModel.marbleScene(viewModel.scene, marbleDidStop: marbleID, at: farFromAnyHole)

        XCTAssertNotEqual(viewModel.phase, .choosingPalmo)
        XCTAssertFalse(viewModel.palmoAvailable)
    }

    func testMissingAHoleOffersPalmoUnderOncePerAttemptPolicy() {
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: true),
        ]
        var rules = GameRules.default
        rules.palmoPolicy = .oncePerAttempt
        let viewModel = GameViewModel(players: players, rules: rules)
        viewModel.configureField(size: CGSize(width: 400, height: 300))

        let marbleID = viewModel.marbles[0].id
        viewModel.phase = .marbleMoving
        let farFromAnyHole = CGPoint(x: -1000, y: -1000)
        viewModel.marbleScene(viewModel.scene, marbleDidStop: marbleID, at: farFromAnyHole)

        XCTAssertEqual(viewModel.phase, .choosingPalmo)
        XCTAssertTrue(viewModel.palmoAvailable)
    }
}
