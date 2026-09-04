import XCTest
@testable import iMarble

final class OnlineMultiplayerTests: XCTestCase {

    func testNetworkGameEventRoundTripsLaunch() throws {
        let event = NetworkGameEvent.launch(marbleID: UUID(), dragVector: NetworkVector(dx: 12.5, dy: -8))
        let data = try XCTUnwrap(event.encoded())
        let decoded = try XCTUnwrap(NetworkGameEvent.decode(data))
        XCTAssertEqual(event, decoded)
    }

    func testNetworkGameEventRoundTripsMatchSetup() throws {
        let players = [
            Player(name: "A", colorName: "red", isHuman: true, gamePlayerID: "p1"),
            Player(name: "B", colorName: "blue", isHuman: true, gamePlayerID: "p2"),
        ]
        let event = NetworkGameEvent.matchSetup(players: players, rules: .default, mode: .mound, hostPlayerID: "p1")
        let data = try XCTUnwrap(event.encoded())
        let decoded = try XCTUnwrap(NetworkGameEvent.decode(data))
        XCTAssertEqual(event, decoded)
    }

    func testNetworkGameEventRoundTripsMoundAndChaseLaunch() throws {
        let events: [NetworkGameEvent] = [
            .moundLaunch(dragVector: NetworkVector(dx: 3, dy: -4)),
            .chaseLaunch(dragVector: NetworkVector(dx: -1.5, dy: 9)),
        ]
        for event in events {
            let data = try XCTUnwrap(event.encoded())
            let decoded = try XCTUnwrap(NetworkGameEvent.decode(data))
            XCTAssertEqual(event, decoded)
        }
    }

    func testNetworkGameEventRoundTripsTargetAndDisconnect() throws {
        let marbleID = UUID()
        let targetID = UUID()
        let events: [NetworkGameEvent] = [
            .selectAttackTarget(marbleID: marbleID, targetID: targetID),
            .peerDisconnected(playerID: "p1"),
        ]
        for event in events {
            let data = try XCTUnwrap(event.encoded())
            let decoded = try XCTUnwrap(NetworkGameEvent.decode(data))
            XCTAssertEqual(event, decoded)
        }
    }

    func testHostElectionPicksAlphabeticallySmallestID() {
        let host = OnlineGameCoordinator.electHost(playerIDs: ["zzz", "abc", "mmm"])
        XCTAssertEqual(host, "abc")
    }

    func testHostElectionSingleParticipant() {
        let host = OnlineGameCoordinator.electHost(playerIDs: ["only"])
        XCTAssertEqual(host, "only")
    }

    private func makeOnlineViewModel(localPlayerID: String) -> (GameViewModel, UUID, UUID) {
        let localPlayer = Player(name: "Local", colorName: "red", isHuman: true, gamePlayerID: localPlayerID)
        let remotePlayer = Player(name: "Remote", colorName: "blue", isHuman: true, gamePlayerID: "remote-id")
        let viewModel = GameViewModel(players: [localPlayer, remotePlayer], rules: .default)
        viewModel.localPlayerID = localPlayerID
        viewModel.configureField(size: CGSize(width: 400, height: 800))
        return (viewModel, viewModel.marbles[0].id, viewModel.marbles[1].id)
    }

    func testCanLaunchGatedToLocalPlayerWhenItIsTheirTurn() {
        let (viewModel, localMarbleID, _) = makeOnlineViewModel(localPlayerID: "local-id")
        XCTAssertTrue(viewModel.marbleScene(viewModel.scene, canLaunch: localMarbleID))
    }

    func testCanLaunchBlockedForRemotePlayersMarbleEvenOnTheirTurn() {
        let (viewModel, _, remoteMarbleID) = makeOnlineViewModel(localPlayerID: "local-id")
        XCTAssertFalse(viewModel.marbleScene(viewModel.scene, canLaunch: remoteMarbleID))
    }

    func testCanLaunchBlockedWhenItIsNotLocalPlayersTurn() {
        let localPlayer = Player(name: "Local", colorName: "red", isHuman: true, gamePlayerID: "not-current")
        let remotePlayer = Player(name: "Remote", colorName: "blue", isHuman: true, gamePlayerID: "remote-id")
        let viewModel = GameViewModel(players: [localPlayer, remotePlayer], rules: .default)
        viewModel.localPlayerID = "not-current"
        viewModel.configureField(size: CGSize(width: 400, height: 800))
        let currentMarbleID = viewModel.marbles[0].id
        XCTAssertTrue(viewModel.marbleScene(viewModel.scene, canLaunch: currentMarbleID))

        viewModel.localPlayerID = "someone-else"
        XCTAssertFalse(viewModel.marbleScene(viewModel.scene, canLaunch: currentMarbleID))
    }

    func testMoundCanLaunchBlockedWhenItIsNotLocalPlayersTurn() {
        let localPlayer = Player(name: "Local", colorName: "red", isHuman: true, gamePlayerID: "local-id")
        let remotePlayer = Player(name: "Remote", colorName: "blue", isHuman: true, gamePlayerID: "remote-id")
        let viewModel = MoundGameViewModel(players: [localPlayer, remotePlayer], rules: .default)
        viewModel.configureField(size: CGSize(width: 400, height: 800))
        let shooterID = try! XCTUnwrap(viewModel.shooterID)
        XCTAssertTrue(viewModel.moundScene(viewModel.scene, canLaunchShooter: shooterID))

        viewModel.localPlayerID = "remote-id"
        XCTAssertFalse(viewModel.moundScene(viewModel.scene, canLaunchShooter: shooterID))
    }

    func testChaseCanLaunchBlockedWhenItIsNotLocalPlayersTurn() {
        let fleeingPlayer = Player(name: "Fleeing", colorName: "red", isHuman: true, gamePlayerID: "local-id")
        let chasingPlayer = Player(name: "Chasing", colorName: "blue", isHuman: true, gamePlayerID: "remote-id")
        let viewModel = ChaseGameViewModel(players: [fleeingPlayer, chasingPlayer], rules: .default)
        viewModel.configureField(size: CGSize(width: 400, height: 800))
        let activeID = try! XCTUnwrap(viewModel.activeMarbleID)
        XCTAssertTrue(viewModel.chaseScene(viewModel.scene, canLaunch: activeID))

        viewModel.localPlayerID = "remote-id"
        XCTAssertFalse(viewModel.chaseScene(viewModel.scene, canLaunch: activeID))
    }

    func testOfflineModeIsUnaffectedByGating() {
        let localPlayer = Player(name: "P1", colorName: "red", isHuman: true)
        let botPlayer = Player(name: "P2", colorName: "blue", isHuman: false)
        let viewModel = GameViewModel(players: [localPlayer, botPlayer], rules: .default)
        viewModel.configureField(size: CGSize(width: 400, height: 800))
        XCTAssertNil(viewModel.localPlayerID)
        XCTAssertTrue(viewModel.marbleScene(viewModel.scene, canLaunch: viewModel.marbles[0].id))
    }
}
