import Foundation

enum GamePhase: Equatable {
    case setup
    case determiningOrder
    case aiming
    case choosingPalmo
    case marbleMoving
    case resolvingHole
    case attacking
    case turnEnded
    case gameOver
}
