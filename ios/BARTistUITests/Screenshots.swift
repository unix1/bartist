import XCTest

@MainActor
final class Screenshots: XCTestCase {
    func testScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launchArguments += ["-bartist.station", "EMBR", "-bartist.appearance", "system"]

        captureSet(
            app,
            appearance: .light,
            trains: "01-Trains",
            stations: "02-Stations",
            map: "03-Map",
            settings: "04-Settings"
        )
        captureSet(
            app,
            appearance: .dark,
            trains: "05-Trains-Dark",
            stations: "06-Stations-Dark",
            map: "07-Map-Dark",
            settings: "08-Settings-Dark"
        )
    }

    private func captureSet(
        _ app: XCUIApplication,
        appearance: XCUIDevice.Appearance,
        trains: String,
        stations: String,
        map: String,
        settings: String
    ) {
        XCUIDevice.shared.appearance = appearance
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
        snapshot(trains)

        station.tap()
        XCTAssertTrue(app.navigationBars["Select a station"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.descendants(matching: .any)["station-EMBR"].waitForExistence(timeout: 8))
        snapshot(stations)

        app.buttons["Back"].tap()
        XCTAssertTrue(station.waitForExistence(timeout: 8))

        tapTab(app, "Map")
        XCTAssertTrue(app.descendants(matching: .any)["map-screen"].waitForExistence(timeout: 8))
        snapshot(map)

        tapTab(app, "Settings")
        XCTAssertTrue(app.descendants(matching: .any)["settings-screen"].waitForExistence(timeout: 8))
        snapshot(settings)

        app.terminate()
    }

    /// iOS 27 Duo does not expose a TabBar to XCTest; fall back to any matching control.
    private func tapTab(_ app: XCUIApplication, _ name: String) {
        let tabBar = app.tabBars.buttons[name]
        if tabBar.exists {
            tabBar.tap()
            return
        }
        let button = app.buttons[name]
        if button.exists {
            button.tap()
            return
        }
        let any = app.descendants(matching: .any)[name]
        XCTAssertTrue(any.waitForExistence(timeout: 8), "\(name) tab")
        any.firstMatch.tap()
    }
}
