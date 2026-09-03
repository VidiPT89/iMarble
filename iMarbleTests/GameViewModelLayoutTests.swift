import XCTest
import CoreGraphics
@testable import iMarble

final class GameViewModelLayoutTests: XCTestCase {
    private func makeViewModel() -> GameViewModel {
        let players = [
            Player(name: "P1", colorName: "orange", isHuman: true),
            Player(name: "P2", colorName: "blue", isHuman: true),
        ]
        return GameViewModel(players: players, rules: .default)
    }

    func testConfigureFieldIsIdempotentAndDelegatesToLayout() {
        let viewModel = makeViewModel()
        let initialSize = CGSize(width: 400, height: 300)
        viewModel.configureField(size: initialSize)

        let holePositionsBefore = viewModel.holes.map(\.position)
        let marblePositionsBefore = viewModel.marbles.map(\.position)

        let newSize = CGSize(width: 300, height: 400)
        viewModel.configureField(size: newSize)

        XCTAssertNotEqual(viewModel.holes.map(\.position), holePositionsBefore)
        XCTAssertNotEqual(viewModel.marbles.map(\.position), marblePositionsBefore)
    }

    func testLayoutFieldPreservesRelativePosition() {
        let viewModel = makeViewModel()
        let initialSize = CGSize(width: 400, height: 300)
        viewModel.configureField(size: initialSize)

        guard let firstHole = viewModel.holes.first else {
            return XCTFail("expected at least one hole")
        }
        let relativeX = firstHole.position.x / Double(initialSize.width)
        let relativeY = firstHole.position.y / Double(initialSize.height)

        let newSize = CGSize(width: 300, height: 600)
        viewModel.layoutField(size: newSize)

        guard let holeAfter = viewModel.holes.first else {
            return XCTFail("expected at least one hole")
        }
        let newRelativeX = holeAfter.position.x / Double(newSize.width)
        let newRelativeY = holeAfter.position.y / Double(newSize.height)

        XCTAssertEqual(relativeX, newRelativeX, accuracy: 0.0001)
        XCTAssertEqual(relativeY, newRelativeY, accuracy: 0.0001)
    }

    func testLayoutFieldDoesNotResetGamePhase() {
        let viewModel = makeViewModel()
        viewModel.configureField(size: CGSize(width: 400, height: 300))
        viewModel.phase = .marbleMoving

        viewModel.layoutField(size: CGSize(width: 300, height: 500))

        XCTAssertEqual(viewModel.phase, .marbleMoving)
    }

    func testLayoutFieldIgnoresUnchangedSize() {
        let viewModel = makeViewModel()
        let size = CGSize(width: 400, height: 300)
        viewModel.configureField(size: size)
        let holesBefore = viewModel.holes.map(\.position)

        viewModel.layoutField(size: size)

        XCTAssertEqual(viewModel.holes.map(\.position), holesBefore)
    }
}
