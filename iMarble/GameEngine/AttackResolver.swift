import Foundation

enum AttackResolver {
    static func resolveAttack(
        attacker: Marble,
        attackerCompletedCourse: Bool = true,
        attackerAtHole: Bool = true,
        target: Marble,
        rules: GameRules
    ) -> Bool {
        guard !rules.attackRequiresCourseCompletion || attackerCompletedCourse else { return false }
        guard !rules.attackRequiresHoleLaunch || attackerAtHole else { return false }
        guard attacker.ownerID != target.ownerID else { return false }
        guard !target.isInsideHole || !rules.protectedMarblesInsideHoles else { return false }
        guard !target.isProtected else { return false }
        let distance = attacker.position.distance(to: target.position)
        return distance <= GameRules.attackHitDistance
    }

    static func eligibleTargets(marbles: [Marble], attackerOwnerID: UUID, rules: GameRules) -> [Marble] {
        marbles.filter { marble in
            marble.ownerID != attackerOwnerID &&
            !marble.isCaptured &&
            !(marble.isInsideHole && rules.protectedMarblesInsideHoles) &&
            !marble.isProtected
        }
    }
}
