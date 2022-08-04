//
//  TileMocks.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 2/8/22.
//

import Foundation
@testable import TileFeed

extension URLTile {
    static var mock: Self {
        URLTile(
            id: UUID(),
            title: "Test title",
            subtitle: "Test subtitle",
            ranking: 10,
            type: .image,
            url: URL(string: "https://www.apple.com")!
        )
    }
}

extension ShoppingTile {
    static var mock: Self {
        ShoppingTile(
            id: UUID(),
            title: "Test title",
            subtitle: "Test subtitle",
            ranking: 10,
            cartItems: ["An item"]
        )
    }
}
