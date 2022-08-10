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
    }

    func testTitle() {
        let welcome = app.staticTexts["Welcome back!"]

        XCTAssert(welcome.exists)
    }

    func testNavigation() {
        app.launch()

        let tile = app.tables.buttons.element(boundBy: 0)
        XCTAssert(tile.exists)
        tile.tapUnhittable() //Needed to avoid random isHittable == false

        app.navigationBars.buttons["Welcome back!"].tap()
    }
}

//MARK: - Utils

extension XCUIElement {
    func tapUnhittable() {
        XCTContext.runActivity(named: "Tap \(self) by coordinate") { _ in
            coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }
}
