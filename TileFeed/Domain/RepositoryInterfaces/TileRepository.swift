//
//  TileRepository.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import Combine
import Foundation

protocol TileRepository {
    func updateLastRefreshDate(to date: Date)
    func getLastRefreshDate() -> Date?
    func fetchTiles(refresh: Bool) -> AnyPublisher<[Tile], Error>
    func saveTiles(_ tiles: [Tile]) -> AnyPublisher<[Tile], Error>
    func addCartItem(_ item: String, to shoppingTile: ShoppingTile) -> AnyPublisher<[String], Error>
}
