import Foundation

enum GameMode: String, Codable, CaseIterable, Identifiable {
    case covas
    case mound

    var id: String { rawValue }
}

struct MoundRules: Codable, Equatable {
    var circleRadius: Double
    var marblesPerPlayer: Int
    var burnLosesShooter: Bool

    static let `default` = MoundRules(circleRadius: 70, marblesPerPlayer: 3, burnLosesShooter: false)
}
