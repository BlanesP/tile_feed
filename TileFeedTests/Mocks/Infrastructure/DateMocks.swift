//
//  DateMocks.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import Foundation

extension Date {
    static func mockDate(from dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: dateString)!
    }

    static var yesterday: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
}
