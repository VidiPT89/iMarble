import CoreGraphics
import Foundation

struct NetworkVector: Codable, Equatable {
    var dx: Double
    var dy: Double

    var cgVector: CGVector { CGVector(dx: dx, dy: dy) }

    init(dx: Double, dy: Double) {
        self.dx = dx
        self.dy = dy
    }

    init(_ vector: CGVector) {
        self.dx = Double(vector.dx)
        self.dy = Double(vector.dy)
    }
}

enum NetworkGameEvent: Codable, Equatable {
    case matchSetup(players: [Player], rules: GameRules, hostPlayerID: String)
    case launch(marbleID: UUID, dragVector: NetworkVector)
    case palmo(marbleID: UUID, vector: NetworkVector)
    case skipPalmo(marbleID: UUID)
    case selectAttackTarget(marbleID: UUID, targetID: UUID)
    case peerDisconnected(playerID: String)

    private enum CodingKeys: String, CodingKey {
        case type, players, rules, hostPlayerID, marbleID, dragVector, vector, targetID, playerID
    }

    private enum Kind: String, Codable {
        case matchSetup, launch, palmo, skipPalmo, selectAttackTarget, peerDisconnected
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .matchSetup:
            self = .matchSetup(
                players: try container.decode([Player].self, forKey: .players),
                rules: try container.decode(GameRules.self, forKey: .rules),
                hostPlayerID: try container.decode(String.self, forKey: .hostPlayerID)
            )
        case .launch:
            self = .launch(
                marbleID: try container.decode(UUID.self, forKey: .marbleID),
                dragVector: try container.decode(NetworkVector.self, forKey: .dragVector)
            )
        case .palmo:
            self = .palmo(
                marbleID: try container.decode(UUID.self, forKey: .marbleID),
                vector: try container.decode(NetworkVector.self, forKey: .vector)
            )
        case .skipPalmo:
            self = .skipPalmo(marbleID: try container.decode(UUID.self, forKey: .marbleID))
        case .selectAttackTarget:
            self = .selectAttackTarget(
                marbleID: try container.decode(UUID.self, forKey: .marbleID),
                targetID: try container.decode(UUID.self, forKey: .targetID)
            )
        case .peerDisconnected:
            self = .peerDisconnected(playerID: try container.decode(String.self, forKey: .playerID))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .matchSetup(players, rules, hostPlayerID):
            try container.encode(Kind.matchSetup, forKey: .type)
            try container.encode(players, forKey: .players)
            try container.encode(rules, forKey: .rules)
            try container.encode(hostPlayerID, forKey: .hostPlayerID)
        case let .launch(marbleID, dragVector):
            try container.encode(Kind.launch, forKey: .type)
            try container.encode(marbleID, forKey: .marbleID)
            try container.encode(dragVector, forKey: .dragVector)
        case let .palmo(marbleID, vector):
            try container.encode(Kind.palmo, forKey: .type)
            try container.encode(marbleID, forKey: .marbleID)
            try container.encode(vector, forKey: .vector)
        case let .skipPalmo(marbleID):
            try container.encode(Kind.skipPalmo, forKey: .type)
            try container.encode(marbleID, forKey: .marbleID)
        case let .selectAttackTarget(marbleID, targetID):
            try container.encode(Kind.selectAttackTarget, forKey: .type)
            try container.encode(marbleID, forKey: .marbleID)
            try container.encode(targetID, forKey: .targetID)
        case let .peerDisconnected(playerID):
            try container.encode(Kind.peerDisconnected, forKey: .type)
            try container.encode(playerID, forKey: .playerID)
        }
    }

    func encoded() -> Data? {
        try? JSONEncoder().encode(self)
    }

    static func decode(_ data: Data) -> NetworkGameEvent? {
        try? JSONDecoder().decode(NetworkGameEvent.self, from: data)
    }
}
