import XCTest

@MainActor
final class Screenshots: XCTestCase {
    func testScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-bartist.station", "EMBR"]
        app.launch()

        let station = app.buttons["selected-station"]
        XCTAssertTrue(station.waitForExistence(timeout: 20))

        let named = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "label == %@", "Embarcadero"),
            object: station
        )
        XCTAssertEqual(
            XCTWaiter.wait(for: [named], timeout: 20),
            .completed,
            "Station chip should show Embarcadero"
        )

        let ready = app.descendants(matching: .any)["trains-ready"]
        XCTAssertTrue(ready.waitForExistence(timeout: 30), "Trains should finish loading")
        snapshot("01-Trains")

        station.tap()
        XCTAssertTrue(app.navigationBars["Select a station"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["station-EMBR"].waitForExistence(timeout: 8))
        snapshot("02-Stations")

        app.buttons["Back"].tap()
        XCTAssertTrue(station.waitForExistence(timeout: 8))

        app.tabBars.buttons["Map"].tap()
        XCTAssertTrue(app.descendants(matching: .any)["map-screen"].waitForExistence(timeout: 8))
        snapshot("03-Map")
    }
}
