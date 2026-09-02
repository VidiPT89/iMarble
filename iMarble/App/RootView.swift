import SwiftUI

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            } else {
                MainMenuView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(SettingsViewModel())
        .environmentObject(LocalizationManager.shared)
}
