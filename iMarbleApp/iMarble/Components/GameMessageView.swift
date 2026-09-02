import SwiftUI

struct GameMessageView: View {
    @EnvironmentObject private var localization: LocalizationManager
    let key: LocalizedKey

    var body: some View {
        Text(localization.string(key))
            .font(AppTheme.Typography.body())
            .foregroundStyle(AppTheme.cream)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(Color.black.opacity(0.5))
                    .overlay(Capsule().stroke(AppTheme.burntYellow.opacity(0.6), lineWidth: 1))
            )
            .id(key)
            .transition(.opacity.combined(with: .move(edge: .top)))
            .animation(.easeInOut(duration: 0.25), value: key)
    }
}

#Preview {
    GameMessageView(key: .yourTurn)
        .environmentObject(LocalizationManager.shared)
        .padding()
        .background(Color.black)
}
