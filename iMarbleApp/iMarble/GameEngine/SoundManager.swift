import AudioToolbox

enum GameSound {
    case launch
    case collision
    case holeEntered
    case hit
    case victory
}

final class SoundManager {
    static let shared = SoundManager()
    var isEnabled = true
    private init() {}

    func play(_ sound: GameSound) {
        guard isEnabled else { return }
        let systemSoundID: SystemSoundID
        switch sound {
        case .launch: systemSoundID = 1104
        case .collision: systemSoundID = 1105
        case .holeEntered: systemSoundID = 1025
        case .hit: systemSoundID = 1057
        case .victory: systemSoundID = 1025
        }
        AudioServicesPlaySystemSound(systemSoundID)
    }
}
