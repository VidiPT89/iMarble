import Foundation

struct Marble: Identifiable, Codable, Equatable {
    let id: UUID
    let ownerID: UUID
    var position: CodablePoint
    var isInsideHole: Bool
    var isProtected: Bool
    var isCaptured: Bool
    var isMoving: Bool

    init(
        id: UUID = UUID(),
        ownerID: UUID,
        position: CodablePoint,
        isInsideHole: Bool = false,
        isProtected: Bool = false,
        isCaptured: Bool = false,
        isMoving: Bool = false
    ) {
        self.id = id
        self.ownerID = ownerID
        self.position = position
        self.isInsideHole = isInsideHole
        self.isProtected = isProtected
        self.isCaptured = isCaptured
        self.isMoving = isMoving
    }
}
