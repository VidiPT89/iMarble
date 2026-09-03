import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var settings: SettingsViewModel
    @State private var showSetup = false
    @State private var showRules = false
    @State private var showSettings = false
    @State private var showAbout = false
    @State private var showTutorial = false
    @State private var showOnlineGame = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Text(localization.string(.appName))
                    .font(AppTheme.Typography.title())
                    .foregroundStyle(AppTheme.accentGradient)

                Text(localization.string(.tagline))
                    .font(AppTheme.Typography.body())
                    .foregroundStyle(AppTheme.cream.opacity(0.8))

                Spacer()

                VStack(spacing: 14) {
                    Button(localization.string(.play)) { showSetup = true }
                        .buttonStyle(PrimaryButtonStyle())
                        .accessibilityIdentifier("playButton")

                    Button(localization.string(.playOnline)) { showOnlineGame = true }
                        .buttonStyle(SecondaryButtonStyle())
                        .accessibilityIdentifier("playOnlineButton")

                    HStack(spacing: 14) {
                        Button(localization.string(.rules)) { showRules = true }
                            .buttonStyle(SecondaryButtonStyle())
                        Button(localization.string(.settings)) { showSettings = true }
                            .buttonStyle(SecondaryButtonStyle())
                    }
                    Button(localization.string(.about)) { showAbout = true }
                        .buttonStyle(SecondaryButtonStyle())
                }

                Spacer()

                HStack {
                    Button {
                        localization.toggle()
                    } label: {
                        Label(localization.language.displayName, systemImage: "globe")
                            .font(AppTheme.Typography.caption())
                            .foregroundStyle(AppTheme.burntYellow)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
            .padding()
        }
        .onAppear {
            if !settings.hasSeenTutorial {
                showTutorial = true
            }
        }
        .fullScreenCover(isPresented: $showSetup) {
            SetupGameView()
        }
        .fullScreenCover(isPresented: $showOnlineGame) {
            OnlineGameContainerView()
        }
        .sheet(isPresented: $showRules) {
            RulesView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView {
                settings.hasSeenTutorial = true
                showTutorial = false
            }
        }
    }
}

#Preview {
    MainMenuView()
        .environmentObject(SettingsViewModel())
        .environmentObject(LocalizationManager.shared)
}
