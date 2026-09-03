import XCTest

final class GameScreenSnapshotTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testGameScreenLandscapeAndPortraitSnapshots() throws {
        let app = XCUIApplication()
        app.launch()

        let skipButton = app.buttons["tutorialSkip"]
        if skipButton.waitForExistence(timeout: 5) {
            skipButton.tap()
        }

        let playButton = app.buttons["playButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5))
        playButton.tap()

        let startButton = app.buttons["startGameButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let board = app.otherElements["gameBoard"]
        XCTAssertTrue(board.waitForExistence(timeout: 8))

        XCUIDevice.shared.orientation = .landscapeLeft
        Thread.sleep(forTimeInterval: 1.0)
        attachScreenshot(named: "game-landscape")

        XCUIDevice.shared.orientation = .portrait
        Thread.sleep(forTimeInterval: 1.0)
        attachScreenshot(named: "game-portrait")
    }

    func testDragGestureCompletesWithoutError() throws {
        let app = XCUIApplication()
        app.launch()

        let skipButton = app.buttons["tutorialSkip"]
        if skipButton.waitForExistence(timeout: 5) {
            skipButton.tap()
        }

        let playButton = app.buttons["playButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5))
        playButton.tap()

        let startButton = app.buttons["startGameButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        let board = app.otherElements["gameBoard"]
        XCTAssertTrue(board.waitForExistence(timeout: 8))
        Thread.sleep(forTimeInterval: 0.5)

        let marbleStart = board.coordinate(withNormalizedOffset: CGVector(dx: 0.42, dy: 0.08))
        let dragTarget = board.coordinate(withNormalizedOffset: CGVector(dx: 0.55, dy: 0.25))
        marbleStart.press(forDuration: 0.1, thenDragTo: dragTarget, withVelocity: .slow, thenHoldForDuration: 0.3)

        Thread.sleep(forTimeInterval: 1.5)
        attachScreenshot(named: "after-launch")
        XCTAssertTrue(app.state == .runningForeground)
    }

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
