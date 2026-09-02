import SwiftUI

struct RulesView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    Text(localization.string(.rulesBody))
                        .font(AppTheme.Typography.body())
                        .foregroundStyle(AppTheme.cream)
                        .padding()
                }
            }
            .navigationTitle(localization.string(.rulesTitle))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.string(.close)) { dismiss() }
                }
            }
        }
    }
}

struct AboutView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                VStack(spacing: 16) {
                    Text(localization.string(.aboutBody))
                        .font(AppTheme.Typography.body())
                        .foregroundStyle(AppTheme.cream)
                        .multilineTextAlignment(.center)
                    Text(localization.string(.developedBy))
                        .font(AppTheme.Typography.caption())
                        .foregroundStyle(AppTheme.burntYellow)
                    Text("https://ividi.dev/")
                        .font(AppTheme.Typography.caption())
                        .foregroundStyle(AppTheme.burntYellow.opacity(0.8))
                }
                .padding()
            }
            .navigationTitle(localization.string(.aboutTitle))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.string(.close)) { dismiss() }
                }
            }
        }
    }
}

#Preview {
    RulesView().environmentObject(LocalizationManager.shared)
}
