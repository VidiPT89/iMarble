import XCTest
@testable import iMarble

final class MoundEngineTests: XCTestCase {
    private let center = CGPoint(x: 100, y: 100)
    private let radius: CGFloat = 50

    func testMarbleOutsideCircleIsCaptured() {
        let owner = UUID()
        let marble = MoundMarble(ownerID: owner, position: CodablePoint(x: 200, y: 100))
        let result = MoundEngine.resolveShot(shooterFinalPosition: CGPoint(x: 0, y: 0), pileMarbles: [marble], center: center, radius: radius)
        XCTAssertEqual(result.capturedMarbleIDs, [marble.id])
    }

    func testMarbleInsideCircleIsNotCaptured() {
        let owner = UUID()
        let marble = MoundMarble(ownerID: owner, position: CodablePoint(x: 110, y: 100))
        let result = MoundEngine.resolveShot(shooterFinalPosition: CGPoint(x: 0, y: 0), pileMarbles: [marble], center: center, radius: radius)
        XCTAssertTrue(result.capturedMarbleIDs.isEmpty)
    }

    func testAlreadyCapturedMarbleIsNotCapturedAgain() {
        let owner = UUID()
        let marble = MoundMarble(ownerID: owner, position: CodablePoint(x: 200, y: 100), isCaptured: true)
        let result = MoundEngine.resolveShot(shooterFinalPosition: CGPoint(x: 0, y: 0), pileMarbles: [marble], center: center, radius: radius)
        XCTAssertTrue(result.capturedMarbleIDs.isEmpty)
    }

    func testShooterInsideCircleBurns() {
        let result = MoundEngine.resolveShot(shooterFinalPosition: CGPoint(x: 105, y: 100), pileMarbles: [], center: center, radius: radius)
        XCTAssertTrue(result.burned)
    }

    func testShooterOutsideCircleDoesNotBurn() {
        let result = MoundEngine.resolveShot(shooterFinalPosition: CGPoint(x: 300, y: 100), pileMarbles: [], center: center, radius: radius)
        XCTAssertFalse(result.burned)
    }

    func testRoundOverWhenAllMarblesCaptured() {
        let owner = UUID()
        let marbles = [
            MoundMarble(ownerID: owner, position: CodablePoint(x: 0, y: 0), isCaptured: true),
            MoundMarble(ownerID: owner, position: CodablePoint(x: 0, y: 0), isCaptured: true),
        ]
        XCTAssertTrue(MoundEngine.isRoundOver(pileMarbles: marbles))
    }

    func testRoundNotOverWhileMarblesRemain() {
        let owner = UUID()
        let marbles = [
            MoundMarble(ownerID: owner, position: CodablePoint(x: 0, y: 0), isCaptured: true),
            MoundMarble(ownerID: owner, position: CodablePoint(x: 0, y: 0), isCaptured: false),
        ]
        XCTAssertFalse(MoundEngine.isRoundOver(pileMarbles: marbles))
    }

    func testWinnerIsPlayerWithMostCaptures() {
        let a = Player(name: "A", colorName: "orange", isHuman: true, capturedMarbleCount: 3)
        let b = Player(name: "B", colorName: "yellow", isHuman: false, capturedMarbleCount: 1)
        XCTAssertEqual(MoundEngine.winner(players: [a, b])?.name, "A")
    }

    func testWinnerIsNilOnTie() {
        let a = Player(name: "A", colorName: "orange", isHuman: true, capturedMarbleCount: 2)
        let b = Player(name: "B", colorName: "yellow", isHuman: false, capturedMarbleCount: 2)
        XCTAssertNil(MoundEngine.winner(players: [a, b]))
    }

    func testWinnerIsNilWhenNoOneHasCaptured() {
        let a = Player(name: "A", colorName: "orange", isHuman: true)
        let b = Player(name: "B", colorName: "yellow", isHuman: false)
        XCTAssertNil(MoundEngine.winner(players: [a, b]))
    }
}
