//
//  Logger.swift
//  TileFeed
//
//  Created by Pau Blanes on 1/8/22.
//

import Foundation

protocol Logger { }

extension Logger {
    func log(_ msg: String) {
        print("[DEBUG LOG] -> \(String(describing: type(of: self))): \(msg)")
    }
}
