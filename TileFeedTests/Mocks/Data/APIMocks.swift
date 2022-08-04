//
//  APIMocks.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 2/8/22.
//

@testable import TileFeed

extension TileRequest.Response {
    static var mockImageTile: Tile {
        return Tile(
            name: "image",
            headline: "Test title",
            subline: "Test subtitle",
            data: "https://www.apple.com",
            score: 50
        )
    }

    static var mockShoppingTile: Tile {
        return Tile(
            name: "shopping_list",
            headline: "Test title",
            subline: "Test subtitle",
            data: nil,
            score: 50
        )
    }
}
