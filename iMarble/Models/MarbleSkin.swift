import Foundation

struct MarbleSkin: Identifiable, Equatable {
    let id: String
    let nameKey: LocalizedKey
    let colorName: String
    let winsRequired: Int

    static let all: [MarbleSkin] = [
        MarbleSkin(id: "classic", nameKey: .skinClassic, colorName: "orange", winsRequired: 0),
        MarbleSkin(id: "cateye", nameKey: .skinCatEye, colorName: "cateye", winsRequired: 3),
        MarbleSkin(id: "ox", nameKey: .skinOx, colorName: "ox", winsRequired: 7),
        MarbleSkin(id: "grandmarble", nameKey: .skinGrandMarble, colorName: "grandmarble", winsRequired: 12),
    ]

    static func isUnlocked(_ skin: MarbleSkin, totalWins: Int) -> Bool {
        totalWins >= skin.winsRequired
    }
}

struct Terrain: Identifiable, Equatable {
    let id: String
    let nameKey: LocalizedKey
    let baseColor: (red: Double, green: Double, blue: Double)
    let speckColor: (red: Double, green: Double, blue: Double)
    let winsRequired: Int

    static func == (lhs: Terrain, rhs: Terrain) -> Bool { lhs.id == rhs.id }

    static let all: [Terrain] = [
        Terrain(id: "dirt", nameKey: .terrainDirt, baseColor: (0.22, 0.14, 0.06), speckColor: (0.34, 0.23, 0.11), winsRequired: 0),
        Terrain(id: "schoolyard", nameKey: .terrainSchoolyard, baseColor: (0.30, 0.29, 0.27), speckColor: (0.42, 0.41, 0.38), winsRequired: 4),
        Terrain(id: "backyard", nameKey: .terrainBackyard, baseColor: (0.14, 0.22, 0.10), speckColor: (0.24, 0.34, 0.16), winsRequired: 8),
        Terrain(id: "plaza", nameKey: .terrainPlaza, baseColor: (0.32, 0.27, 0.20), speckColor: (0.46, 0.40, 0.30), winsRequired: 15),
    ]

    static func isUnlocked(_ terrain: Terrain, totalWins: Int) -> Bool {
        totalWins >= terrain.winsRequired
    }
}

struct Achievement: Identifiable {
    let id: String
    let titleKey: LocalizedKey
    let isUnlocked: (ProgressStore) -> Bool

    static let all: [Achievement] = [
        Achievement(id: "firstWin", titleKey: .achievementFirstWin) { $0.totalWins >= 1 },
        Achievement(id: "fiveWins", titleKey: .achievementFiveWins) { $0.totalWins >= 5 },
        Achievement(id: "winStreak", titleKey: .achievementWinStreak) { $0.winStreak >= 10 },
        Achievement(id: "fullCollection", titleKey: .achievementFullCollection) { store in
            MarbleSkin.all.allSatisfy { MarbleSkin.isUnlocked($0, totalWins: store.totalWins) }
                && Terrain.all.allSatisfy { Terrain.isUnlocked($0, totalWins: store.totalWins) }
        },
    ]
}
