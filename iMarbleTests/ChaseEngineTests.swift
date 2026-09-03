import XCTest
@testable import iMarble

final class ChaseEngineTests: XCTestCase {
    func testHitDetectedWithinRadius() {
        let hit = ChaseEngine.isHit(chaserFinalPosition: CGPoint(x: 100, y: 100), fleeingPosition: CGPoint(x: 105, y: 100), hitRadius: 10)
        XCTAssertTrue(hit)
    }

    func testHitNotDetectedOutsideRadius() {
        let hit = ChaseEngine.isHit(chaserFinalPosition: CGPoint(x: 100, y: 100), fleeingPosition: CGPoint(x: 200, y: 100), hitRadius: 10)
        XCTAssertFalse(hit)
    }

    func testRolesSwapOnMiss() {
        let result = ChaseEngine.nextRoles(hit: false, fleeingIndex: 0, chasingIndex: 1)
        XCTAssertEqual(result.fleeing, 1)
        XCTAssertEqual(result.chasing, 0)
    }

    func testRolesStaySameOnHit() {
        let result = ChaseEngine.nextRoles(hit: true, fleeingIndex: 0, chasingIndex: 1)
        XCTAssertEqual(result.fleeing, 0)
        XCTAssertEqual(result.chasing, 1)
    }

    func testWinnerReachedTargetPoints() {
        let a = Player(name: "A", colorName: "orange", score: 5, isHuman: true)
        let b = Player(name: "B", colorName: "yellow", score: 2, isHuman: false)
        XCTAssertEqual(ChaseEngine.winner(players: [a, b], targetPoints: 5)?.name, "A")
    }

    func testWinnerNilBelowTarget() {
        let a = Player(name: "A", colorName: "orange", score: 3, isHuman: true)
        let b = Player(name: "B", colorName: "yellow", score: 2, isHuman: false)
        XCTAssertNil(ChaseEngine.winner(players: [a, b], targetPoints: 5))
    }
}
