import Foundation

final class TurnManager {
    private(set) var currentPlayerIndex: Int
    private(set) var order: [Int]

    init(playerCount: Int, order: [Int]? = nil) {
        self.order = order ?? Array(0..<playerCount)
        self.currentPlayerIndex = 0
    }

    var currentOrderPosition: Int { currentPlayerIndex }

    var activePlayerOrderIndex: Int {
        order[currentPlayerIndex % order.count]
    }

    func advance(activePlayers: [Bool]) {
        guard !order.isEmpty else { return }
        var attempts = 0
        repeat {
            currentPlayerIndex = (currentPlayerIndex + 1) % order.count
            attempts += 1
        } while attempts <= order.count && !activePlayers[order[currentPlayerIndex]]
    }

    func setOrder(_ newOrder: [Int]) {
        order = newOrder
        currentPlayerIndex = 0
    }

    func remainingActiveCount(activePlayers: [Bool]) -> Int {
        activePlayers.filter { $0 }.count
    }
}
