//
//  CoreDataSourceMock.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 2/8/22.
//

import Combine
import CoreData
@testable import TileFeed

final class CoreDataSourceMock: BaseMock {
    var result: Any?

    var actionParams: Any?
    var updateTileCalled = false

    private let context: NSManagedObjectContext
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension CoreDataSourceMock: CoreDataSource {
    func fetchAllTiles() -> AnyPublisher<[TileEntity], Error> {
        mockPublisherResult()
    }

    func regenerateTiles(action: @escaping (NSManagedObjectContext) -> Void) -> AnyPublisher<Void, Error> {
        action(context)
        return mockPublisherResult()
    }

    func updateTile<T: TileEntity>(request: NSFetchRequest<T>, action: @escaping (T) -> Void) -> AnyPublisher<T, Error>  {
        updateTileCalled = true
        if let actionParams = self.actionParams as? T {
            action(actionParams)
        }
        return mockPublisherResult()
    }
}
