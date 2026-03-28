import XCTest
@testable import WorktualAIBot

final class WorktualAIBotTests: XCTestCase {

    func testConfigBuildURL() {
        let config = WorktualAIBotConfig(webchatId: "testID123")
        let url = config.buildURL()
        XCTAssertNotNil(url)
        XCTAssertTrue(url!.absoluteString.contains("webchatid=testID123"))
        XCTAssertTrue(url!.absoluteString.contains("isHeader=1"))
    }

    func testConfigDefaultValues() {
        let config = WorktualAIBotConfig(webchatId: "abc")
        XCTAssertEqual(config.loadingTitle, "AI Assistant")
        XCTAssertEqual(config.loadingSubtitle, "Loading your chat...")
        XCTAssertEqual(config.maxLoadTimeMs, 6000)
        XCTAssertNil(config.loadingLogo)
    }
}
