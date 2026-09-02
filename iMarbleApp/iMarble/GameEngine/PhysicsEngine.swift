import CoreGraphics
import Foundation

enum PhysicsEngine {
    static func velocity(fromDrag dragVector: CGVector, rules: GameRules) -> CGVector {
        let length = sqrt(dragVector.dx * dragVector.dx + dragVector.dy * dragVector.dy)
        guard length > 0 else { return .zero }
        let power = min(length, rules.maximumDragDistanceValue)
        let normalized = CGVector(dx: dragVector.dx / length, dy: dragVector.dy / length)
        var vx = normalized.dx * power * rules.powerMultiplierValue
        var vy = normalized.dy * power * rules.powerMultiplierValue
        let speed = sqrt(vx * vx + vy * vy)
        if speed > GameRules.maximumLaunchSpeed {
            let scale = GameRules.maximumLaunchSpeed / speed
            vx *= scale
            vy *= scale
        }
        return CGVector(dx: vx, dy: vy)
    }

    static func applyFriction(velocity: CGVector) -> CGVector {
        CGVector(dx: velocity.dx * GameRules.frictionCoefficient, dy: velocity.dy * GameRules.frictionCoefficient)
    }

    static func hasStopped(velocity: CGVector) -> Bool {
        let speed = sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
        return speed < GameRules.minimumStopSpeed
    }

    static func clampPosition(_ position: CGPoint, in bounds: CGRect, radius: CGFloat) -> CGPoint {
        var p = position
        p.x = min(max(p.x, bounds.minX + radius), bounds.maxX - radius)
        p.y = min(max(p.y, bounds.minY + radius), bounds.maxY - radius)
        return p
    }
}

private extension GameRules {
    var maximumDragDistanceValue: CGFloat { CGFloat(GameRules.maximumDragDistance) }
    var powerMultiplierValue: CGFloat { CGFloat(GameRules.powerMultiplier) }
}
