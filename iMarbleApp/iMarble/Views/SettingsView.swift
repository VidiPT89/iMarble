import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var settings: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showTutorial = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                Form {
                    Section(localization.string(.appearance)) {
                        Picker(localization.string(.appearance), selection: $settings.colorScheme) {
                            Text(localization.string(.appearanceSystem)).tag(AppColorScheme.system)
                            Text(localization.string(.appearanceLight)).tag(AppColorScheme.light)
                            Text(localization.string(.appearanceDark)).tag(AppColorScheme.dark)
                        }
                        .pickerStyle(.segmented)
                    }

                    Section(localization.string(.language)) {
                        Picker(localization.string(.language), selection: $localization.language) {
                            ForEach(AppLanguage.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section {
                        Toggle(localization.string(.soundLabel), isOn: $settings.soundEnabled)
                        Toggle(localization.string(.hapticsLabel), isOn: $settings.hapticsEnabled)
                        Toggle(localization.string(.reduceMotion), isOn: $settings.reduceMotion)
                    }

                    Section {
                        Button(localization.string(.replayTutorial)) {
                            showTutorial = true
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(localization.string(.settingsTitle))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.string(.close)) { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showTutorial) {
                TutorialView { showTutorial = false }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(LocalizationManager.shared)
}
