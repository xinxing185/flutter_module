import XCTest

final class HostFlowTests: XCTestCase {
    func testFlutterOpensNativeDetails() {
        let app = launchHost()
        app.buttons["open-flutter-demo"].tap()
        let nativeDetails = app.buttons["Open Native Device Details"]
        XCTAssertTrue(nativeDetails.waitForExistence(timeout: 20))

        for _ in 0..<2 {
            nativeDetails.tap()
            XCTAssertTrue(app.staticTexts["ID: ios-mock-A"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.staticTexts["Model: iOS Mock"].exists)
            XCTAssertTrue(app.staticTexts["MAC: 00:00:00:00:00:01"].exists)
            app.buttons["native-device-detail-back"].tap()
            XCTAssertTrue(nativeDetails.waitForExistence(timeout: 10))
        }

        app.buttons["Back"].tap()
        XCTAssertTrue(app.buttons["open-flutter-demo"].waitForExistence(timeout: 10))
    }

    func testDeviceApiAcceptsAnotherMethod() {
        let app = launchHost()
        app.buttons["open-device-api-test"].tap()
        func response(_ text: String) -> XCUIElement {
            app.descendants(matching: .any)
                .matching(NSPredicate(format: "label CONTAINS %@ OR value CONTAINS %@", text, text))
                .firstMatch
        }

        XCTAssertTrue(response("\"uptime\": 1").waitForExistence(timeout: 20))
        let method = app.textFields.firstMatch
        method.tap()
        method.typeText("custom")
        XCTAssertTrue((method.value as? String)?.contains("custom") == true)
        app.buttons["Run"].tap()
        XCTAssertTrue(response("\"uptime\": 2").waitForExistence(timeout: 10))
    }

    func testFeedbackOpensFromHost() {
        let app = launchHost()
        app.buttons["open-feedback"].tap()
        let addMedia = app.buttons["Add photos or videos from the gallery"]
        XCTAssertTrue(addMedia.waitForExistence(timeout: 20), app.debugDescription)
    }

    private func launchHost() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["open-flutter-demo"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["open-device-api-test"].exists)
        XCTAssertTrue(app.buttons["open-feedback"].exists)
        XCTAssertEqual(app.buttons.count, 3)
        return app
    }
}
