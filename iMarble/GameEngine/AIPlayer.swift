import CoreGraphics
import Foundation

struct AIDecision {
    var dragVector: CGVector
    var attackTargetID: UUID?
}

enum AIPlayer {
    static func decideMove(
        difficulty: AIDifficulty,
        marblePosition: CodablePoint,
        targetPosition: CodablePoint,
        opponentMarbles: [Marble],
        canAttack: Bool,
        rules: GameRules
    ) -> AIDecision {
        if canAttack, let target = chooseAttackTarget(difficulty: difficulty, from: marblePosition, opponents: opponentMarbles) {
            let vector = aimVector(from: marblePosition, to: target.position, difficulty: difficulty)
            return AIDecision(dragVector: vector, attackTargetID: target.id)
        }
        let vector = aimVector(from: marblePosition, to: targetPosition, difficulty: difficulty)
        return AIDecision(dragVector: vector, attackTargetID: nil)
    }

    private static func chooseAttackTarget(difficulty: AIDifficulty, from position: CodablePoint, opponents: [Marble]) -> Marble? {
        guard !opponents.isEmpty else { return nil }
        switch difficulty {
        case .easy:
            return opponents.randomElement()
        case .normal, .hard:
            return opponents.min { position.distance(to: $0.position) < position.distance(to: $1.position) }
        }
    }

    static func aimVector(from: CodablePoint, to: CodablePoint, difficulty: AIDifficulty) -> CGVector {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance > 0 else { return CGVector(dx: 0, dy: 0) }

        let errorMagnitude: Double
        switch difficulty {
        case .easy: errorMagnitude = 0.35
        case .normal: errorMagnitude = 0.15
        case .hard: errorMagnitude = 0.05
        }

        let angleError = Double.random(in: -errorMagnitude...errorMagnitude)
        let baseAngle = atan2(dy, dx)
        let angle = baseAngle + angleError

        let forceRatio = min(distance / GameRules.maximumDragDistance, 1.0)
        let forceError: Double
        switch difficulty {
        case .easy: forceError = Double.random(in: -0.3...0.15)
        case .normal: forceError = Double.random(in: -0.15...0.1)
        case .hard: forceError = Double.random(in: -0.05...0.05)
        }
        let power = min(max(forceRatio + forceError, 0.15), 1.0) * GameRules.maximumDragDistance

        // `dragVector` is consumed directly as the launch direction (see
        // PhysicsEngine.velocity(fromDrag:) and MarbleScene.touchesEnded,
        // which pass `dragStart - point` — already the travel direction,
        // not a pull-back vector), so it must point toward the target.
        let dragDx = cos(angle) * power
        let dragDy = sin(angle) * power
        return CGVector(dx: dragDx, dy: dragDy)
    }
}
