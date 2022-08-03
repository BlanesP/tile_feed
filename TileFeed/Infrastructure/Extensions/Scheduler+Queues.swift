//
//  Scheduler+Queues.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import Combine
import Dispatch

extension Scheduler where Self == DispatchQueue {
    static var main: Self { DispatchQueue.main }
    static var global: Self { DispatchQueue.global() }
}
