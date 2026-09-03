import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @ObservedObject private var progress = ProgressStore.shared
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 96), spacing: 14)]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(localization.string(.collectionSkinsSection))
                            .font(AppTheme.Typography.headline())
                            .foregroundStyle(AppTheme.burntYellow)

                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(MarbleSkin.all) { skin in
                                skinCell(skin)
                            }
                        }

                        Text(localization.string(.collectionTerrainsSection))
                            .font(AppTheme.Typography.headline())
                            .foregroundStyle(AppTheme.burntYellow)
                            .padding(.top, 8)

                        LazyVGrid(columns: columns, spacing: 18) {
                            ForEach(Terrain.all) { terrain in
                                terrainCell(terrain)
                            }
                        }

                        Text(localization.string(.collectionAchievementsSection))
                            .font(AppTheme.Typography.headline())
                            .foregroundStyle(AppTheme.burntYellow)
                            .padding(.top, 8)

                        VStack(spacing: 10) {
                            ForEach(Achievement.all) { achievement in
                                achievementRow(achievement)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(localization.string(.collectionTitle))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.string(.close)) { dismiss() }
                }
            }
        }
    }

    private func skinCell(_ skin: MarbleSkin) -> some View {
        let unlocked = progress.isUnlocked(skin)
        let selected = progress.selectedSkinID == skin.id
        return VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(AppTheme.color(named: skin.colorName))
                    .frame(width: 56, height: 56)
                    .opacity(unlocked ? 1 : 0.25)
                    .overlay(
                        Circle().stroke(selected ? AppTheme.burntYellow : .clear, lineWidth: 3)
                    )
                if !unlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(AppTheme.cream)
                }
            }
            Text(localization.string(skin.nameKey))
                .font(AppTheme.Typography.caption())
                .foregroundStyle(AppTheme.cream)
                .multilineTextAlignment(.center)
            if unlocked {
                Text(selected ? localization.string(.collectionSelected) : localization.string(.collectionSelect))
                    .font(.caption2)
                    .foregroundStyle(selected ? AppTheme.burntYellow : AppTheme.cream.opacity(0.7))
            } else {
                Text(String(format: localization.string(.collectionLockedWithWins), skin.winsRequired))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.cream.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .onTapGesture {
            guard unlocked else { return }
            progress.selectedSkinID = skin.id
        }
    }

    private func terrainCell(_ terrain: Terrain) -> some View {
        let unlocked = progress.isUnlocked(terrain)
        let selected = progress.selectedTerrainID == terrain.id
        let color = Color(red: terrain.baseColor.red, green: terrain.baseColor.green, blue: terrain.baseColor.blue)
        return VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .frame(width: 56, height: 56)
                    .opacity(unlocked ? 1 : 0.25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10).stroke(selected ? AppTheme.burntYellow : .clear, lineWidth: 3)
                    )
                if !unlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(AppTheme.cream)
                }
            }
            Text(localization.string(terrain.nameKey))
                .font(AppTheme.Typography.caption())
                .foregroundStyle(AppTheme.cream)
                .multilineTextAlignment(.center)
            if unlocked {
                Text(selected ? localization.string(.collectionSelected) : localization.string(.collectionSelect))
                    .font(.caption2)
                    .foregroundStyle(selected ? AppTheme.burntYellow : AppTheme.cream.opacity(0.7))
            } else {
                Text(String(format: localization.string(.collectionLockedWithWins), terrain.winsRequired))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.cream.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .onTapGesture {
            guard unlocked else { return }
            progress.selectedTerrainID = terrain.id
        }
    }

    private func achievementRow(_ achievement: Achievement) -> some View {
        let unlocked = achievement.isUnlocked(progress)
        return HStack {
            Image(systemName: unlocked ? "rosette" : "lock.fill")
                .foregroundStyle(unlocked ? AppTheme.burntYellow : AppTheme.cream.opacity(0.4))
            Text(localization.string(achievement.titleKey))
                .foregroundStyle(unlocked ? AppTheme.cream : AppTheme.cream.opacity(0.4))
            Spacer()
        }
        .font(AppTheme.Typography.body())
        .padding(.horizontal, 4)
    }
}

#Preview {
    CollectionView().environmentObject(LocalizationManager.shared)
}
