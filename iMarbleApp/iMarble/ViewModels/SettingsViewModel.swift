import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var colorScheme: AppColorScheme {
        didSet { UserDefaults.standard.set(colorScheme.rawValue, forKey: Self.schemeKey) }
    }
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: Self.soundKey) }
    }
    @Published var hapticsEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticsEnabled, forKey: Self.hapticsKey) }
    }
    @Published var reduceMotion: Bool {
        didSet { UserDefaults.standard.set(reduceMotion, forKey: Self.reduceMotionKey) }
    }
    @Published var hasSeenTutorial: Bool {
        didSet { UserDefaults.standard.set(hasSeenTutorial, forKey: Self.tutorialKey) }
    }

    private static let schemeKey = "settings.colorScheme"
    private static let soundKey = "settings.sound"
    private static let hapticsKey = "settings.haptics"
    private static let reduceMotionKey = "settings.reduceMotion"
    private static let tutorialKey = "settings.hasSeenTutorial"

    init() {
        let defaults = UserDefaults.standard
        if let raw = defaults.string(forKey: Self.schemeKey), let scheme = AppColorScheme(rawValue: raw) {
            colorScheme = scheme
        } else {
            colorScheme = .system
        }
        soundEnabled = defaults.object(forKey: Self.soundKey) as? Bool ?? true
        hapticsEnabled = defaults.object(forKey: Self.hapticsKey) as? Bool ?? true
        reduceMotion = defaults.object(forKey: Self.reduceMotionKey) as? Bool ?? false
        hasSeenTutorial = defaults.object(forKey: Self.tutorialKey) as? Bool ?? false
    }
}
