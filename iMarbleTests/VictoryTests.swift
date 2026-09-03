import XCTest
@testable import iMarble

final class VictoryTests: XCTestCase {
    func testClassicVictoryWithOneRemainingPlayer() {
        let engine = GameEngine(rules: .default)
        var players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: false, isEliminated: true),
        ]
        let winner = engine.checkVictory(players: players)
        XCTAssertEqual(winner?.name, "A")
        _ = players
    }

    func testClassicVictoryReturnsNilWhenMultipleRemain() {
        let engine = GameEngine(rules: .default)
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true),
            Player(name: "B", colorName: "yellow", isHuman: false),
        ]
        XCTAssertNil(engine.checkVictory(players: players))
    }

    func testPointsVictoryWhenTargetReached() {
        var rules = GameRules.default
        rules.victoryMode = .points
        rules.targetScore = 10
        let engine = GameEngine(rules: rules)
        let players = [
            Player(name: "A", colorName: "orange", score: 12, isHuman: true),
            Player(name: "B", colorName: "yellow", score: 4, isHuman: false),
        ]
        XCTAssertEqual(engine.checkVictory(players: players)?.name, "A")
    }

    func testPointsVictoryReturnsNilBelowTarget() {
        var rules = GameRules.default
        rules.victoryMode = .points
        rules.targetScore = 20
        let engine = GameEngine(rules: rules)
        let players = [
            Player(name: "A", colorName: "orange", score: 12, isHuman: true),
        ]
        XCTAssertNil(engine.checkVictory(players: players))
    }

    func testClassicVictoryWhenPlayerCompletesCourseWithoutLosingMarble() {
        let engine = GameEngine(rules: .default)
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true, hasCompletedCourse: true),
            Player(name: "B", colorName: "yellow", isHuman: false, hasCompletedCourse: false),
        ]
        XCTAssertEqual(engine.checkVictory(players: players)?.name, "A")
    }

    func testClassicVictoryTiebreaksByCapturedMarblesWhenMultipleFinish() {
        let engine = GameEngine(rules: .default)
        let players = [
            Player(name: "A", colorName: "orange", isHuman: true, hasCompletedCourse: true, capturedMarbleCount: 1),
            Player(name: "B", colorName: "yellow", isHuman: false, hasCompletedCourse: true, capturedMarbleCount: 2),
        ]
        XCTAssertEqual(engine.checkVictory(players: players)?.name, "B")
    }

    func testProcessAttackPermanentlyCapturesMarbleAndEliminatesOwner() {
        let engine = GameEngine(rules: .default)
        var attacker = Player(name: "A", colorName: "orange", isHuman: true, hasCompletedCourse: true)
        let attackerMarble = Marble(ownerID: attacker.id, position: CodablePoint(x: 0, y: 0), isInsideHole: true)
        var targetOwner = Player(name: "B", colorName: "yellow", isHuman: false)
        var target = Marble(ownerID: targetOwner.id, position: CodablePoint(x: 5, y: 0))

        let success = engine.processAttack(attacker: &attacker, attackerMarble: attackerMarble, target: &target, targetOwner: &targetOwner)

        XCTAssertTrue(success)
        XCTAssertTrue(target.isCaptured)
        XCTAssertEqual(attacker.capturedMarbleCount, 1)
        XCTAssertTrue(targetOwner.isEliminated)
    }

    func testProcessAttackRejectedWhenAttackerHasNotCompletedCourse() {
        let engine = GameEngine(rules: .default)
        var attacker = Player(name: "A", colorName: "orange", isHuman: true, hasCompletedCourse: false)
        let attackerMarble = Marble(ownerID: attacker.id, position: CodablePoint(x: 0, y: 0), isInsideHole: true)
        var targetOwner = Player(name: "B", colorName: "yellow", isHuman: false)
        var target = Marble(ownerID: targetOwner.id, position: CodablePoint(x: 5, y: 0))

        let success = engine.processAttack(attacker: &attacker, attackerMarble: attackerMarble, target: &target, targetOwner: &targetOwner)

        XCTAssertFalse(success)
        XCTAssertFalse(target.isCaptured)
    }

    func testProcessHoleEntryUpdatesProgressAndScore() {
        let engine = GameEngine(rules: .default)
        var player = Player(name: "A", colorName: "orange", isHuman: true)
        var marble = Marble(ownerID: player.id, position: CodablePoint(x: 100, y: 100))
        let hole = Hole(number: 1, position: CodablePoint(x: 100, y: 100), radius: 20)
        let entered = engine.processHoleEntry(player: &player, marble: &marble, holes: [hole])
        XCTAssertTrue(entered)
        XCTAssertEqual(player.progressIndex, 1)
        XCTAssertEqual(player.score, ScoreRules.enterHole)
        XCTAssertTrue(marble.isInsideHole)
    }
}
