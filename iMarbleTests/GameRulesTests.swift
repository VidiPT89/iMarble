import XCTest
@testable import iMarble

final class GameRulesTests: XCTestCase {
    func testDefaultHoleSequenceIsRoundTrip() {
        XCTAssertEqual(GameRules.default.holeSequence, [1, 2, 3, 2, 1])
    }

    func testOneWayCourseSequence() {
        XCTAssertEqual(CourseType.oneWay.holeSequence, [1, 2, 3])
    }

    func testRoundTripWithPapaSequence() {
        XCTAssertEqual(CourseType.roundTripWithPapa.holeSequence, [1, 2, 3, 2, 1, 0])
    }

    func testHoleResolverDetectsEntry() {
        let hole = Hole(number: 1, position: CodablePoint(x: 100, y: 100), radius: 20)
        let marblePosition = CodablePoint(x: 105, y: 102)
        let entered = HoleResolver.holeEntered(marblePosition: marblePosition, holes: [hole], targetNumber: 1)
        XCTAssertNotNil(entered)
    }

    func testHoleResolverRejectsFarPosition() {
        let hole = Hole(number: 1, position: CodablePoint(x: 100, y: 100), radius: 20)
        let marblePosition = CodablePoint(x: 300, y: 300)
        let entered = HoleResolver.holeEntered(marblePosition: marblePosition, holes: [hole], targetNumber: 1)
        XCTAssertNil(entered)
    }

    func testNextTargetProgression() {
        let sequence = [1, 2, 3]
        XCTAssertEqual(HoleResolver.nextTarget(sequence: sequence, progressIndex: 0), 1)
        XCTAssertEqual(HoleResolver.nextTarget(sequence: sequence, progressIndex: 2), 3)
        XCTAssertNil(HoleResolver.nextTarget(sequence: sequence, progressIndex: 3))
    }

    func testCourseCompletionDetection() {
        XCTAssertTrue(HoleResolver.hasCompletedCourse(sequence: [1, 2, 3], progressIndex: 3))
        XCTAssertFalse(HoleResolver.hasCompletedCourse(sequence: [1, 2, 3], progressIndex: 2))
    }

    func testAttackResolverRejectsProtectedMarble() {
        let attackerID = UUID()
        let targetID = UUID()
        let attacker = Marble(ownerID: attackerID, position: CodablePoint(x: 0, y: 0))
        var target = Marble(ownerID: targetID, position: CodablePoint(x: 5, y: 5))
        target.isProtected = true
        let rules = GameRules.default
        XCTAssertFalse(AttackResolver.resolveAttack(attacker: attacker, target: target, rules: rules))
    }

    func testAttackResolverRejectsSelfHit() {
        let ownerID = UUID()
        let attacker = Marble(ownerID: ownerID, position: CodablePoint(x: 0, y: 0))
        let target = Marble(ownerID: ownerID, position: CodablePoint(x: 5, y: 5))
        XCTAssertFalse(AttackResolver.resolveAttack(attacker: attacker, target: target, rules: .default))
    }

    func testAttackResolverAcceptsCloseHit() {
        let attacker = Marble(ownerID: UUID(), position: CodablePoint(x: 0, y: 0))
        let target = Marble(ownerID: UUID(), position: CodablePoint(x: 10, y: 0))
        XCTAssertTrue(AttackResolver.resolveAttack(attacker: attacker, target: target, rules: .default))
    }

    func testAttackResolverRejectsAttackBeforeCourseCompletion() {
        let attacker = Marble(ownerID: UUID(), position: CodablePoint(x: 0, y: 0))
        let target = Marble(ownerID: UUID(), position: CodablePoint(x: 10, y: 0))
        XCTAssertFalse(AttackResolver.resolveAttack(
            attacker: attacker,
            attackerCompletedCourse: false,
            attackerAtHole: true,
            target: target,
            rules: .default
        ))
    }

    func testAttackResolverRejectsAttackNotFromHole() {
        let attacker = Marble(ownerID: UUID(), position: CodablePoint(x: 0, y: 0))
        let target = Marble(ownerID: UUID(), position: CodablePoint(x: 10, y: 0))
        XCTAssertFalse(AttackResolver.resolveAttack(
            attacker: attacker,
            attackerCompletedCourse: true,
            attackerAtHole: false,
            target: target,
            rules: .default
        ))
    }

    func testAttackResolverAcceptsAttackFromHoleAfterCourse() {
        let attacker = Marble(ownerID: UUID(), position: CodablePoint(x: 0, y: 0))
        let target = Marble(ownerID: UUID(), position: CodablePoint(x: 10, y: 0))
        XCTAssertTrue(AttackResolver.resolveAttack(
            attacker: attacker,
            attackerCompletedCourse: true,
            attackerAtHole: true,
            target: target,
            rules: .default
        ))
    }

    func testDefaultScoreValuesMatchPointsVariation() {
        XCTAssertEqual(ScoreRules.enterHole, 2)
        XCTAssertEqual(ScoreRules.hitOpponent, 2)
        XCTAssertEqual(ScoreRules.captureMarble, 3)
    }
}
