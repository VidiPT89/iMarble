import XCTest
@testable import iMarble

final class TurnManagerTests: XCTestCase {
    func testInitialPlayerIsFirst() {
        let manager = TurnManager(playerCount: 3)
        XCTAssertEqual(manager.activePlayerOrderIndex, 0)
    }

    func testAdvanceMovesToNextPlayer() {
        let manager = TurnManager(playerCount: 3)
        manager.advance(activePlayers: [true, true, true])
        XCTAssertEqual(manager.activePlayerOrderIndex, 1)
    }

    func testAdvanceWrapsAround() {
        let manager = TurnManager(playerCount: 2)
        manager.advance(activePlayers: [true, true])
        manager.advance(activePlayers: [true, true])
        XCTAssertEqual(manager.activePlayerOrderIndex, 0)
    }

    func testAdvanceSkipsEliminatedPlayers() {
        let manager = TurnManager(playerCount: 3)
        manager.advance(activePlayers: [true, false, true])
        XCTAssertEqual(manager.activePlayerOrderIndex, 2)
    }

    func testRemainingActiveCount() {
        let manager = TurnManager(playerCount: 4)
        XCTAssertEqual(manager.remainingActiveCount(activePlayers: [true, false, true, false]), 2)
    }
}
