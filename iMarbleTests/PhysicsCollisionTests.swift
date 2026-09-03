import XCTest
@testable import iMarble

final class PhysicsCollisionTests: XCTestCase {
    func testMovingMarbleTransfersVelocityToStationaryMarbleOnHeadOnHit() {
        let a = CGPoint(x: 0, y: 0)
        let b = CGPoint(x: 10, y: 0)
        let (newA, newB) = PhysicsEngine.resolveCollision(
            velocityA: CGVector(dx: 100, dy: 0),
            velocityB: .zero,
            positionA: a,
            positionB: b
        )
        XCTAssertEqual(newA.dx, 0, accuracy: 0.001)
        XCTAssertEqual(newB.dx, 100, accuracy: 0.001)
    }

    func testMarblesMovingApartAreNotAffected() {
        let a = CGPoint(x: 0, y: 0)
        let b = CGPoint(x: 10, y: 0)
        let (newA, newB) = PhysicsEngine.resolveCollision(
            velocityA: CGVector(dx: -50, dy: 0),
            velocityB: CGVector(dx: 50, dy: 0),
            positionA: a,
            positionB: b
        )
        XCTAssertEqual(newA.dx, -50, accuracy: 0.001)
        XCTAssertEqual(newB.dx, 50, accuracy: 0.001)
    }

    func testCoincidentPositionsReturnInputVelocitiesUnchanged() {
        let p = CGPoint(x: 5, y: 5)
        let (newA, newB) = PhysicsEngine.resolveCollision(
            velocityA: CGVector(dx: 10, dy: 0),
            velocityB: CGVector(dx: 0, dy: 0),
            positionA: p,
            positionB: p
        )
        XCTAssertEqual(newA.dx, 10, accuracy: 0.001)
        XCTAssertEqual(newB.dx, 0, accuracy: 0.001)
    }
}
