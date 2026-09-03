import Foundation

enum TournamentEngine {
    static let stageOrder: [GameMode] = [.covas, .mound, .chase]

    /// A stage win is worth 1 point; a tied stage (no winner) awards nothing,
    /// keeping the tournament simple regardless of each stage's own scoring scale.
    static func scoresAfterStageWin(current: [UUID: Int], winnerID: UUID?) -> [UUID: Int] {
        guard let winnerID else { return current }
        var updated = current
        updated[winnerID, default: 0] += 1
        return updated
    }

    static func isTournamentOver(completedStages: Int) -> Bool {
        completedStages >= stageOrder.count
    }

    static func overallWinnerID(scores: [UUID: Int]) -> UUID? {
        guard let maxScore = scores.values.max(), maxScore > 0 else { return nil }
        let leaders = scores.filter { $0.value == maxScore }
        return leaders.count == 1 ? leaders.keys.first : nil
    }
}
