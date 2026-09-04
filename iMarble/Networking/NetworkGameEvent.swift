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
    case matchSetup(players: [Player], rules: GameRules, mode: GameMode, hostPlayerID: String)
    case launch(marbleID: UUID, dragVector: NetworkVector)
    case selectAttackTarget(marbleID: UUID, targetID: UUID)
    /// Mound/Chase each ever have exactly one launchable marble at a time,
    /// and that marble's id is generated fresh, independently, on every
    /// device each turn — so unlike `.launch`, these carry no id and are
    /// applied to whichever marble the local view model already knows is
    /// launchable, keeping both devices in sync via turn state alone.
    case moundLaunch(dragVector: NetworkVector)
    case chaseLaunch(dragVector: NetworkVector)
    case peerDisconnected(playerID: String)

    private enum CodingKeys: String, CodingKey {
        case type, players, rules, mode, hostPlayerID, marbleID, dragVector, targetID, playerID
    }

    private enum Kind: String, Codable {
        case matchSetup, launch, selectAttackTarget, moundLaunch, chaseLaunch, peerDisconnected
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .type)
        switch kind {
        case .matchSetup:
            self = .matchSetup(
                players: try container.decode([Player].self, forKey: .players),
                rules: try container.decode(GameRules.self, forKey: .rules),
                mode: try container.decodeIfPresent(GameMode.self, forKey: .mode) ?? .covas,
                hostPlayerID: try container.decode(String.self, forKey: .hostPlayerID)
            )
        case .launch:
            self = .launch(
                marbleID: try container.decode(UUID.self, forKey: .marbleID),
                dragVector: try container.decode(NetworkVector.self, forKey: .dragVector)
            )
        case .selectAttackTarget:
            self = .selectAttackTarget(
                marbleID: try container.decode(UUID.self, forKey: .marbleID),
                targetID: try container.decode(UUID.self, forKey: .targetID)
            )
        case .moundLaunch:
            self = .moundLaunch(dragVector: try container.decode(NetworkVector.self, forKey: .dragVector))
        case .chaseLaunch:
            self = .chaseLaunch(dragVector: try container.decode(NetworkVector.self, forKey: .dragVector))
        case .peerDisconnected:
            self = .peerDisconnected(playerID: try container.decode(String.self, forKey: .playerID))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .matchSetup(players, rules, mode, hostPlayerID):
            try container.encode(Kind.matchSetup, forKey: .type)
            try container.encode(players, forKey: .players)
            try container.encode(rules, forKey: .rules)
            try container.encode(mode, forKey: .mode)
            try container.encode(hostPlayerID, forKey: .hostPlayerID)
        case let .launch(marbleID, dragVector):
            try container.encode(Kind.launch, forKey: .type)
            try container.encode(marbleID, forKey: .marbleID)
            try container.encode(dragVector, forKey: .dragVector)
        case let .selectAttackTarget(marbleID, targetID):
            try container.encode(Kind.selectAttackTarget, forKey: .type)
            try container.encode(marbleID, forKey: .marbleID)
            try container.encode(targetID, forKey: .targetID)
        case let .moundLaunch(dragVector):
            try container.encode(Kind.moundLaunch, forKey: .type)
            try container.encode(dragVector, forKey: .dragVector)
        case let .chaseLaunch(dragVector):
            try container.encode(Kind.chaseLaunch, forKey: .type)
            try container.encode(dragVector, forKey: .dragVector)
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
