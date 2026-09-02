import Foundation
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case portuguese = "pt"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .portuguese: return "Português"
        case .english: return "English"
        }
    }
}

final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
        }
    }

    private static let storageKey = "app.language"

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Self.storageKey),
           let lang = AppLanguage(rawValue: saved) {
            language = lang
        } else {
            let preferred = Locale.preferredLanguages.first ?? "pt"
            language = preferred.hasPrefix("en") ? .english : .portuguese
        }
    }

    func string(_ key: LocalizedKey) -> String {
        LocalizedStrings.table[key]?[language] ?? key.rawValue
    }

    func toggle() {
        language = language == .portuguese ? .english : .portuguese
    }
}
