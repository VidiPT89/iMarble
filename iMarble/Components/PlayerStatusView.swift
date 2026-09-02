import SwiftUI

struct PlayerStatusView: View {
    @EnvironmentObject private var localization: LocalizationManager
    let player: Player
    let isActive: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.fill")
                .foregroundStyle(AppTheme.color(named: player.colorName))
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cream)
                Text("\(localization.string(.score)): \(player.score)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.burntYellow)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? AppTheme.orange.opacity(0.25) : Color.black.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? AppTheme.orangeVibrant : .clear, lineWidth: 1.5)
                )
        )
        .opacity(player.isEliminated ? 0.4 : 1)
    }
}

#Preview {
    PlayerStatusView(player: Player(name: "Jogador 1", colorName: "orange", isHuman: true), isActive: true)
        .environmentObject(LocalizationManager.shared)
        .padding()
        .background(Color.black)
}
