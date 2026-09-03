import XCTest
@testable import iMarble

final class AIPlayerTests: XCTestCase {
    func testDecideMoveAimsTowardTheTargetHole() {
        let marblePosition = CodablePoint(x: 0, y: 0)
        let targetPosition = CodablePoint(x: 100, y: 0)

        let decision = AIPlayer.decideMove(
            difficulty: .hard,
            marblePosition: marblePosition,
            targetPosition: targetPosition,
            opponentMarbles: [],
            canAttack: false,
            rules: .default
        )

        // With low angle error at .hard difficulty, the drag vector must
        // point roughly toward the target (positive x), not away from it.
        XCTAssertGreaterThan(decision.dragVector.dx, 0)
    }

    func testDecideMoveAimsTowardTheTargetInEveryDirection() {
        let marblePosition = CodablePoint(x: 200, y: 200)
        let targets: [CodablePoint] = [
            CodablePoint(x: 200, y: 100), // straight up
            CodablePoint(x: 200, y: 300), // straight down
            CodablePoint(x: 100, y: 200), // straight left
            CodablePoint(x: 300, y: 200), // straight right
        ]

        for target in targets {
            let decision = AIPlayer.decideMove(
                difficulty: .hard,
                marblePosition: marblePosition,
                targetPosition: target,
                opponentMarbles: [],
                canAttack: false,
                rules: .default
            )
            let toTarget = CGVector(dx: target.x - marblePosition.x, dy: target.y - marblePosition.y)
            let dot = decision.dragVector.dx * toTarget.dx + decision.dragVector.dy * toTarget.dy
            XCTAssertGreaterThan(dot, 0, "drag vector should point toward \(target), not away from it")
        }
    }
}
