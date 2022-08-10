//
//  TileFeedUITestsLaunchTests.swift
//  TileFeedUITests
//
//  Created by Pau Blanes on 10/8/22.
//

import XCTest

class TileFeedUITestsLaunchTests: XCTestCase {

    let app = XCUIApplication()

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        app.launch()
    }

    func testLaunch() throws {

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
