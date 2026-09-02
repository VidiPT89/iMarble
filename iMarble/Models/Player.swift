import Foundation

enum AIDifficulty: String, Codable, CaseIterable, Identifiable {
    case easy
    case normal
    case hard

    var id: String { rawValue }
}

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var colorName: String
    var score: Int
    var isHuman: Bool
    var isEliminated: Bool
    var aiDifficulty: AIDifficulty
    var progressIndex: Int
    var hasCompletedCourse: Bool
    var capturedMarbleCount: Int

    init(
        id: UUID = UUID(),
        name: String,
        colorName: String,
        score: Int = 0,
        isHuman: Bool,
        isEliminated: Bool = false,
        aiDifficulty: AIDifficulty = .normal,
        progressIndex: Int = 0,
        hasCompletedCourse: Bool = false,
        capturedMarbleCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorName = colorName
        self.score = score
        self.isHuman = isHuman
        self.isEliminated = isEliminated
        self.aiDifficulty = aiDifficulty
        self.progressIndex = progressIndex
        self.hasCompletedCourse = hasCompletedCourse
        self.capturedMarbleCount = capturedMarbleCount
    }
}
