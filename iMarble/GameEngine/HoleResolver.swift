import Foundation

enum HoleResolver {
    static func holeEntered(marblePosition: CodablePoint, holes: [Hole], targetNumber: Int) -> Hole? {
        guard targetNumber > 0 else {
            return holes.first { $0.number == 0 && marblePosition.distance(to: $0.position) <= $0.radius }
        }
        guard let target = holes.first(where: { $0.number == targetNumber }) else { return nil }
        return marblePosition.distance(to: target.position) <= target.radius ? target : nil
    }

    static func nextTarget(sequence: [Int], progressIndex: Int) -> Int? {
        guard progressIndex < sequence.count else { return nil }
        return sequence[progressIndex]
    }

    static func hasCompletedCourse(sequence: [Int], progressIndex: Int) -> Bool {
        progressIndex >= sequence.count
    }
}
