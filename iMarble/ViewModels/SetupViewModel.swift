import Foundation

final class SetupViewModel: ObservableObject {
    @Published var players: [Player]
    @Published var courseType: CourseType = .roundTrip
    @Published var victoryMode: VictoryMode = .classic
    @Published var targetScore: Int = 15
    @Published var numberOfRounds: Int = 3
    @Published var soundEnabled: Bool = true

    init() {
        players = [
            Player(name: "Jogador 1", colorName: AppTheme.playerPalette[0], isHuman: true),
            Player(name: "Computador", colorName: AppTheme.playerPalette[1], isHuman: false, aiDifficulty: .normal),
        ]
    }

    func addPlayer() {
        guard players.count < 4 else { return }
        let index = players.count
        players.append(
            Player(
                name: "Jogador \(index + 1)",
                colorName: AppTheme.playerPalette[index % AppTheme.playerPalette.count],
                isHuman: false,
                aiDifficulty: .normal
            )
        )
    }

    func removePlayer() {
        guard players.count > 2 else { return }
        players.removeLast()
    }

    func buildRules() -> GameRules {
        GameRules(
            numberOfPlayers: players.count,
            courseType: courseType,
            holeSequence: courseType.holeSequence,
            captureMarbles: true,
            extraTurnAfterHole: true,
            extraTurnAfterHit: true,
            protectedMarblesInsideHoles: true,
            allowConsecutiveAttacks: true,
            eliminateOnLastMarbleLost: true,
            attackRequiresCourseCompletion: true,
            attackRequiresHoleLaunch: true,
            victoryMode: victoryMode,
            targetScore: targetScore,
            numberOfRounds: numberOfRounds
        )
    }
}
