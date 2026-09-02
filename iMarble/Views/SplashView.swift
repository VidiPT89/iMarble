import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var localization: LocalizationManager
    var onFinished: () -> Void

    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Image(systemName: "circle.hexagongrid.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92, height: 92)
                    .foregroundStyle(AppTheme.accentGradient)
                    .shadow(color: AppTheme.orange.opacity(0.5), radius: 20)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text(localization.string(.appName))
                    .font(AppTheme.Typography.title())
                    .foregroundStyle(AppTheme.cream)
                    .opacity(opacity)

                Text(localization.string(.tagline))
                    .font(AppTheme.Typography.body())
                    .foregroundStyle(AppTheme.burntYellow)
                    .opacity(opacity)

                Spacer()

                VStack(spacing: 4) {
                    Text(localization.string(.developedBy))
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.cream.opacity(0.8))

                    Text("https://ividi.dev/")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.burntYellow.opacity(0.85))

                    Text("https://github.com/VidiPT89/")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.burntYellow.opacity(0.7))
                }
                .opacity(opacity)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                onFinished()
            }
        }
        .onTapGesture {
            onFinished()
        }
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    SplashView(onFinished: {})
        .environmentObject(LocalizationManager.shared)
}
