import XCTest

final class HostFlowTests: XCTestCase {
    func testRefreshReturnSwitchDeviceAndRetry() {
        let app = XCUIApplication()
        app.launch()
        func element(_ text: String) -> XCUIElement {
            app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", text, text)).firstMatch
        }
        func back() {
            app.buttons["Back"].tap()
            XCTAssertTrue(app.buttons["ios-mock-A"].waitForExistence(timeout: 10))
        }
        app.buttons["ios-mock-A"].tap()
        XCTAssertTrue(element("\"uptime\": 1").waitForExistence(timeout: 20))
        app.buttons["Refresh"].tap()
        XCTAssertTrue(element("\"uptime\": 2").waitForExistence(timeout: 10))
        back()
        app.buttons["ios-mock-B"].tap()
        let switched = element("\"ios-mock-B\"").waitForExistence(timeout: 10)
        if !switched {
            let image = XCTAttachment(screenshot: app.screenshot())
            image.lifetime = .keepAlways
            add(image)
            print(app.debugDescription)
        }
        XCTAssertTrue(switched)
        back()
        app.buttons["open-error"].tap()
        XCTAssertTrue(element("Simulated device error").waitForExistence(timeout: 10))
        app.buttons["Retry"].tap()
        XCTAssertTrue(element("\"ios-mock-A\"").waitForExistence(timeout: 10))
    }
}
