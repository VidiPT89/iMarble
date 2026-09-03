import Foundation

final class GameEngine {
    let rules: GameRules

    init(rules: GameRules) {
        self.rules = rules
    }

    func processHoleEntry(player: inout Player, marble: inout Marble, holes: [Hole]) -> Bool {
        let target = HoleResolver.nextTarget(sequence: rules.holeSequence, progressIndex: player.progressIndex)
        guard let target, let hole = HoleResolver.holeEntered(marblePosition: marble.position, holes: holes, targetNumber: target) else {
            return false
        }
        marble.position = hole.position
        marble.isInsideHole = true
        marble.isProtected = rules.protectedMarblesInsideHoles
        player.progressIndex += 1
        player.score += ScoreRules.enterHole

        if player.progressIndex == 3, rules.courseType != .oneWay {
            // reached furthest hole on the way out, no bonus yet
        }
        if HoleResolver.hasCompletedCourse(sequence: rules.holeSequence, progressIndex: player.progressIndex) {
            player.hasCompletedCourse = true
            switch rules.courseType {
            case .oneWay: player.score += ScoreRules.completeOneWay
            case .roundTrip: player.score += ScoreRules.completeRoundTrip
            case .roundTripWithPapa: player.score += ScoreRules.completePapa
            }
        }
        return true
    }

    func processAttack(attacker: inout Player, attackerMarble: Marble, target: inout Marble, targetOwner: inout Player) -> Bool {
        guard AttackResolver.resolveAttack(
            attacker: attackerMarble,
            attackerCompletedCourse: attacker.hasCompletedCourse,
            attackerAtHole: attackerMarble.isInsideHole,
            target: target,
            rules: rules
        ) else {
            return false
        }
        attacker.score += ScoreRules.hitOpponent
        if rules.captureMarbles {
            target.isCaptured = true
            attacker.score += ScoreRules.captureMarble
            attacker.capturedMarbleCount += 1
            if rules.eliminateOnLastMarbleLost {
                targetOwner.isEliminated = true
            }
        }
        return true
    }

    func checkVictory(players: [Player]) -> Player? {
        switch rules.victoryMode {
        case .classic:
            // Classic mode: whoever completes the course first wins.
            return players.first { $0.hasCompletedCourse }
        case .points:
            return players.first { $0.score >= rules.targetScore }
        }
    }
}
