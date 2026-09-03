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
        },
    ]
}
