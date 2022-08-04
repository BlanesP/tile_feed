//
//  TileRepositoryMock.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import Combine
import Foundation
@testable import TileFeed

final class TileRepositoryMock: BaseMock {
    var result: Any?

    var getDateCalled = false
    var updateDateCalled = false
    var fetchRemoteCalled = false
    var fetchLocalCalled = false
    var saveTilesCalled = false
    var resultDict: [ResultKey: Any?]?
}

extension TileRepositoryMock: TileRepository {
    func updateLastRefreshDate(to date: Date) {
        updateDateCalled = true
    }

    func getLastRefreshDate() -> Date? {
        getDateCalled = true
        if let result = resultDict?[.getDate] { self.result = result }
        return result as? Date
    }

    func fetchTiles(refresh: Bool) -> AnyPublisher<[Tile], Error> {
        if refresh {
            fetchRemoteCalled = true
            if let result = resultDict?[.fetchRemote] {
                self.result = result
            }
        } else {
            fetchLocalCalled = true
            if let result = resultDict?[.fetchLocal] {
               self.result = result
           }
        }
        return mockPublisherResult()
    }

    func saveTiles(_ tiles: [Tile]) -> AnyPublisher<[Tile], Error> {
        saveTilesCalled = true
        if let result = resultDict?[.saveTiles] { self.result = result }
        return mockPublisherResult()
    }

    func addCartItem(_ item: String, to tileId: UUID) -> AnyPublisher<ShoppingTile, Error> {
        mockPublisherResult()
    }
}

extension TileRepositoryMock {
    enum ResultKey {
        case getDate
        case fetchRemote
        case fetchLocal
        case saveTiles
    }
}
