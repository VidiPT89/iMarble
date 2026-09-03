import CoreGraphics
import Foundation

enum ChaseEngine {
    static func isHit(chaserFinalPosition: CGPoint, fleeingPosition: CGPoint, hitRadius: CGFloat) -> Bool {
        chaserFinalPosition.distance(to: fleeingPosition) <= hitRadius
    }

    /// A miss swaps who flees next round; a hit keeps the same roles, per
    /// the traditional rule ("falhar" is what makes you the prey next time).
    static func nextRoles(hit: Bool, fleeingIndex: Int, chasingIndex: Int) -> (fleeing: Int, chasing: Int) {
        hit ? (fleeing: fleeingIndex, chasing: chasingIndex) : (fleeing: chasingIndex, chasing: fleeingIndex)
    }

    static func winner(players: [Player], targetPoints: Int) -> Player? {
        players.first { $0.score >= targetPoints }
    }
}
