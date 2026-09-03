import Foundation

struct MoundMarble: Identifiable, Equatable {
    let id: UUID
    let ownerID: UUID
    var position: CodablePoint
    var isCaptured: Bool

    init(id: UUID = UUID(), ownerID: UUID, position: CodablePoint, isCaptured: Bool = false) {
        self.id = id
        self.ownerID = ownerID
        self.position = position
        self.isCaptured = isCaptured
    }
}
