import SwiftUI

struct TutorialView: View {
    @EnvironmentObject private var localization: LocalizationManager
    var onFinished: () -> Void

    @State private var stepIndex = 0
    private let steps: [LocalizedKey] = [
        .tutorialStep1, .tutorialStep2, .tutorialStep3, .tutorialStep4, .tutorialStep5, .tutorialStep6,
    ]

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 24) {
                Text(localization.string(.tutorialTitle))
                    .font(AppTheme.Typography.headline())
                    .foregroundStyle(AppTheme.orangeVibrant)
                    .padding(.top, 40)

                Spacer()

                Image(systemName: "hand.draw.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .foregroundStyle(AppTheme.accentGradient)

                Text(localization.string(steps[stepIndex]))
                    .font(AppTheme.Typography.body())
                    .foregroundStyle(AppTheme.cream)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .id(stepIndex)
                    .transition(.opacity)

                HStack(spacing: 6) {
                    ForEach(0..<steps.count, id: \.self) { i in
                        Circle()
                            .fill(i == stepIndex ? AppTheme.orangeVibrant : AppTheme.burntYellow.opacity(0.3))
                            .frame(width: 7, height: 7)
                    }
                }

                Spacer()

                HStack {
                    Button(localization.string(.tutorialSkip)) { onFinished() }
                        .buttonStyle(SecondaryButtonStyle())
                    Spacer()
                    Button(stepIndex == steps.count - 1 ? localization.string(.tutorialStart) : localization.string(.tutorialNext)) {
                        if stepIndex == steps.count - 1 {
                            onFinished()
                        } else {
                            withAnimation { stepIndex += 1 }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    TutorialView(onFinished: {})
        .environmentObject(LocalizationManager.shared)
}
