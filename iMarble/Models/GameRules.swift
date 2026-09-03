import Foundation

enum VictoryMode: String, Codable, CaseIterable, Identifiable {
    case classic
    case points

    var id: String { rawValue }
}

enum CourseType: String, Codable, CaseIterable, Identifiable {
    case oneWay
    case roundTrip
    case roundTripWithPapa

    var id: String { rawValue }

    var holeSequence: [Int] {
        switch self {
        case .oneWay: return [1, 2, 3]
        case .roundTrip: return [1, 2, 3, 2, 1]
        case .roundTripWithPapa: return [1, 2, 3, 2, 1, 0]
        }
    }
}

struct GameRules: Codable, Equatable {
    var numberOfPlayers: Int
    var courseType: CourseType
    var holeSequence: [Int]
    var captureMarbles: Bool
    var extraTurnAfterHole: Bool
    var extraTurnAfterHit: Bool
    var protectedMarblesInsideHoles: Bool
    var allowConsecutiveAttacks: Bool
    var eliminateOnLastMarbleLost: Bool
    var attackRequiresCourseCompletion: Bool
    var attackRequiresHoleLaunch: Bool
    var victoryMode: VictoryMode
    var targetScore: Int
    var numberOfRounds: Int

    static let maximumDragDistance: Double = 160
    static let powerMultiplier: Double = 3.4
    static let maximumLaunchSpeed: Double = 620
    static let frictionCoefficient: Double = 0.985
    static let minimumStopSpeed: Double = 4
    static let marbleRadius: Double = 14
    static let holeRadius: Double = 20
    static let attackHitDistance: Double = 26
    static let moveTimeoutSeconds: Double = 6

    static let `default` = GameRules(
        numberOfPlayers: 2,
        courseType: .roundTrip,
        holeSequence: CourseType.roundTrip.holeSequence,
        captureMarbles: true,
        extraTurnAfterHole: true,
        extraTurnAfterHit: true,
        protectedMarblesInsideHoles: true,
        allowConsecutiveAttacks: true,
        eliminateOnLastMarbleLost: true,
        attackRequiresCourseCompletion: true,
        attackRequiresHoleLaunch: true,
        victoryMode: .classic,
        targetScore: 15,
        numberOfRounds: 3
    )
}
