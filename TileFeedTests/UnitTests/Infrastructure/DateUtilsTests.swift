//
//  DateUtilsTests.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import XCTest
@testable import TileFeed

class DateUtilsTests: XCTestCase {

    func testDaysBetweenTodayFromPast() {
        let date = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        XCTAssertEqual(date.daysBetweenToday, 5)
    }

    func testDaysBetweenTodayFromFuture() {
        let date = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        XCTAssertEqual(date.daysBetweenToday, 5)
    }
}
