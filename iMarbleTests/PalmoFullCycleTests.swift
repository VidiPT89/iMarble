import XCTest
@testable import iMarble

final class PalmoFullCycleTests: XCTestCase {
    private func makeViewModel() -> GameViewModel {
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: true),
        ]
        var rules = GameRules.default
        rules.victoryMode = .points
        rules.targetScore = 999
        let viewModel = GameViewModel(players: players, rules: rules)
        viewModel.configureField(size: CGSize(width: 400, height: 300))
        return viewModel
    }

    private func enterHole(_ number: Int, viewModel: GameViewModel, marbleID: UUID) {
        guard let hole = viewModel.holes.first(where: { $0.number == number }) else {
            return XCTFail("hole \(number) missing")
        }
        viewModel.phase = .marbleMoving
        viewModel.marbleScene(viewModel.scene, marbleDidStop: marbleID, at: hole.position.cgPoint)
    }

    func testEnteringHoleOffersPalmoThenAllowsAnotherShotAtTheSameTurn() {
        let viewModel = makeViewModel()
        let marbleID = viewModel.marbles[0].id

        enterHole(1, viewModel: viewModel, marbleID: marbleID)

        XCTAssertEqual(viewModel.phase, .choosingPalmo)
        XCTAssertEqual(viewModel.currentMessageKey, .dragToPalmo)
        XCTAssertTrue(viewModel.palmoAvailable)
        XCTAssertEqual(viewModel.players[0].progressIndex, 1)

        let positionBeforePalmo = viewModel.marbles[0].position.cgPoint
        viewModel.marbleScene(viewModel.scene, didDragPalmo: marbleID, vector: CGVector(dx: 20, dy: 0))
        let positionAfterPalmo = viewModel.marbles[0].position.cgPoint

        XCTAssertNotEqual(positionBeforePalmo, positionAfterPalmo)
        XCTAssertFalse(viewModel.palmoAvailable)
        XCTAssertEqual(viewModel.phase, .aiming, "same player should get to shoot again after the palmo")
        XCTAssertEqual(viewModel.currentPlayer.gamePlayerID, viewModel.players[0].gamePlayerID)
    }

    func testSkippingThePalmoStillLetsThePlayerShootAgain() {
        let viewModel = makeViewModel()
        let marbleID = viewModel.marbles[0].id

        enterHole(1, viewModel: viewModel, marbleID: marbleID)
        XCTAssertEqual(viewModel.phase, .choosingPalmo)

        viewModel.skipPalmo()

        XCTAssertEqual(viewModel.phase, .aiming)
        XCTAssertEqual(viewModel.currentPlayer.id, viewModel.players[0].id, "skipping the palmo must not end the turn, per the extra-turn-after-hole rule")
    }

    func testPalmoIsOfferedAgainAfterEnteringTheSecondHoleInTheSameTurn() {
        let viewModel = makeViewModel()
        let marbleID = viewModel.marbles[0].id

        enterHole(1, viewModel: viewModel, marbleID: marbleID)
        viewModel.marbleScene(viewModel.scene, didDragPalmo: marbleID, vector: CGVector(dx: 20, dy: 0))
        XCTAssertEqual(viewModel.phase, .aiming)

        enterHole(2, viewModel: viewModel, marbleID: marbleID)

        XCTAssertEqual(viewModel.phase, .choosingPalmo, "palmo should be offered again on the next successful hole entry within the same turn")
        XCTAssertTrue(viewModel.palmoAvailable)
        XCTAssertEqual(viewModel.players[0].progressIndex, 2)
    }

    func testMissingAfterUsingThePalmoEndsTheTurn() {
        let viewModel = makeViewModel()
        let marbleID = viewModel.marbles[0].id

        enterHole(1, viewModel: viewModel, marbleID: marbleID)
        viewModel.marbleScene(viewModel.scene, didDragPalmo: marbleID, vector: CGVector(dx: 20, dy: 0))
        XCTAssertEqual(viewModel.phase, .aiming)

        viewModel.phase = .marbleMoving
        let farAway = CGPoint(x: -1000, y: -1000)
        viewModel.marbleScene(viewModel.scene, marbleDidStop: marbleID, at: farAway)

        XCTAssertNotEqual(viewModel.phase, .choosingPalmo, "afterEverySuccess policy must not grant a second palmo on a miss")
        XCTAssertNotEqual(viewModel.currentPlayer.id, viewModel.players[0].id, "missing should end the turn and pass it to the next player")
    }
}
