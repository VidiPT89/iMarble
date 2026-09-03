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

    private func attachScreenshot(named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
