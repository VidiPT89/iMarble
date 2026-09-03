import CoreGraphics
import Foundation

enum MoundEngine {
    struct ShotResult {
        let capturedMarbleIDs: [UUID]
        let burned: Bool
    }

    static func isOutsideCircle(position: CGPoint, center: CGPoint, radius: CGFloat) -> Bool {
        position.distance(to: center) > radius
    }

    static func resolveShot(
        shooterFinalPosition: CGPoint,
        pileMarbles: [MoundMarble],
        center: CGPoint,
        radius: CGFloat
    ) -> ShotResult {
        let captured = pileMarbles
            .filter { !$0.isCaptured && isOutsideCircle(position: $0.position.cgPoint, center: center, radius: radius) }
            .map { $0.id }
        let burned = !isOutsideCircle(position: shooterFinalPosition, center: center, radius: radius)
        return ShotResult(capturedMarbleIDs: captured, burned: burned)
    }

    static func isRoundOver(pileMarbles: [MoundMarble]) -> Bool {
        pileMarbles.allSatisfy { $0.isCaptured }
    }

    /// Whoever captured the most marbles wins; a tie (including 0-0) has no
    /// winner yet.
    static func winner(players: [Player]) -> Player? {
        guard let maxCount = players.map({ $0.capturedMarbleCount }).max(), maxCount > 0 else { return nil }
        let leaders = players.filter { $0.capturedMarbleCount == maxCount }
        return leaders.count == 1 ? leaders.first : nil
    }
}
