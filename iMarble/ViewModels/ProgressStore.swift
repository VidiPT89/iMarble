import Foundation
import Combine

final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    @Published var totalWins: Int {
        didSet { UserDefaults.standard.set(totalWins, forKey: Self.winsKey) }
    }
    @Published var winStreak: Int {
        didSet { UserDefaults.standard.set(winStreak, forKey: Self.streakKey) }
    }
    @Published var selectedSkinID: String {
        didSet { UserDefaults.standard.set(selectedSkinID, forKey: Self.skinKey) }
    }

    private static let winsKey = "progress.totalWins"
    private static let streakKey = "progress.winStreak"
    private static let skinKey = "progress.selectedSkinID"

    init() {
        let defaults = UserDefaults.standard
        totalWins = defaults.integer(forKey: Self.winsKey)
        winStreak = defaults.integer(forKey: Self.streakKey)
        selectedSkinID = defaults.string(forKey: Self.skinKey) ?? MarbleSkin.all[0].id
    }

    /// Called once per finished match; `humanWon` is true when the local
    /// player (not the AI) was the one who won this game.
    func recordMatchResult(humanWon: Bool) {
        if humanWon {
            totalWins += 1
            winStreak += 1
        } else {
            winStreak = 0
        }
    }

    var selectedSkin: MarbleSkin {
        MarbleSkin.all.first { $0.id == selectedSkinID } ?? MarbleSkin.all[0]
    }

    func isUnlocked(_ skin: MarbleSkin) -> Bool {
        MarbleSkin.isUnlocked(skin, totalWins: totalWins)
    }
}
