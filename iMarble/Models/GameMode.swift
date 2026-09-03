import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case covas
    case mound
    case chase
    case tournament

    var id: String { rawValue }
}

struct MoundRules: Codable, Equatable {
    var circleRadius: Double
    var marblesPerPlayer: Int
    var burnLosesShooter: Bool

    static let `default` = MoundRules(circleRadius: 70, marblesPerPlayer: 3, burnLosesShooter: false)
}

struct ChaseRules: Codable, Equatable {
    var targetPoints: Int
    var hitRadius: Double

    static let `default` = ChaseRules(targetPoints: 5, hitRadius: Double(GameRules.marbleRadius) * 2.2)
}
