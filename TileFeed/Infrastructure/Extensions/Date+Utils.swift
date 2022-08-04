//
//  Date+Utils.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import Foundation

//MARK: - Instance

extension Date {
    var daysBetweenToday: Int? {
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: Date())

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        guard let day = components.day else { return nil }
        return abs(day)
    }
}

//MARK: - Static

extension Date {
    static var today: Self { Date() }
}
