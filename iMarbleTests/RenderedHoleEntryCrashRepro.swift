import XCTest
import SpriteKit
@testable import iMarble

final class RenderedHoleEntryCrashRepro: XCTestCase {
    func testHoleEntryWithLiveSKViewDoesNotCrash() {
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: true),
        ]
        var rules = GameRules.default
        rules.victoryMode = .points
        rules.targetScore = 999
        let viewModel = GameViewModel(players: players, rules: rules)

        let view = SKView(frame: CGRect(x: 0, y: 0, width: 400, height: 300))
        view.presentScene(viewModel.scene)

        viewModel.configureField(size: CGSize(width: 400, height: 300))

        let marbleID = viewModel.marbles[0].id
        guard let hole = viewModel.holes.first(where: { $0.number == 1 }) else {
            return XCTFail("hole 1 missing")
        }

        viewModel.phase = .marbleMoving
        viewModel.marbleScene(viewModel.scene, marbleDidStop: marbleID, at: hole.position.cgPoint)

        RunLoop.main.run(until: Date().addingTimeInterval(0.5))

        XCTAssertEqual(viewModel.phase, .choosingPalmo)
    }
}
