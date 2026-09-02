import SwiftUI

@main
struct iMarbleApp: App {
    @StateObject private var settings = SettingsViewModel()
    @StateObject private var localization = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(localization)
                .preferredColorScheme(settings.colorScheme.colorScheme)
        }
    }
}
