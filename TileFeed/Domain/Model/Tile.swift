//
//  Tile.swift
//  TileFeed
//
//  Created by Pau Blanes on 28/7/22.
//

import Foundation

protocol Tile {
    var id: UUID { get }
    var title: String? { get }
    var subtitle: String? { get }
    var ranking: Int { get }
}

struct URLTile: Tile {
    enum URLType: Int {
        case image, video, website
    }

    let id: UUID
    let title: String?
    let subtitle: String?
    let ranking: Int

    let type: URLType
    let url: URL
}

struct ShoppingTile: Tile {
    let id: UUID
    let title: String?
    let subtitle: String?
    let ranking: Int

    var cartItems: [String]
}
