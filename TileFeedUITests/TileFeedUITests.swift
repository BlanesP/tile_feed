//
//  TileFeedUITests.swift
//  TileFeedUITests
//
//  Created by Pau Blanes on 10/8/22.
//

import XCTest

class TileFeedUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app.launch()
    }

    func testTitle() {
        let welcome = app.staticTexts["Welcome back!"]

        XCTAssert(welcome.exists)
    }

    func testNavigation() {
        let tile = app.tables.buttons["iPhone"]
        XCTAssert(tile.exists)
        tile.tap()

        app.navigationBars.buttons["Welcome back!"].tap()
    }
}
