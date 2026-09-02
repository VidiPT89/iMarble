import Foundation

struct Hole: Identifiable, Codable, Equatable {
    let id: UUID
    let number: Int
    var position: CodablePoint
    var radius: Double

    init(id: UUID = UUID(), number: Int, position: CodablePoint, radius: Double) {
        self.id = id
        self.number = number
        self.position = position
        self.radius = radius
    }
}
