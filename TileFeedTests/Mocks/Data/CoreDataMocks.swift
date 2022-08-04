//
//  CoreDataMocks.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 2/8/22.
//

import CoreData
@testable import TileFeed

//MARK: - Entity

extension URLTileEntity {
    static func mock(with context: NSManagedObjectContext) -> URLTileEntity {
        let entity = URLTileEntity(context: context)
        entity.id = UUID()
        entity.title = "Test title"
        entity.subtitle = "Test subtitle"
        entity.ranking = 50
        entity.url = URL(string: "https://www.apple.com")!

        return entity
    }

    func isEqual(to tile: URLTile?) -> Bool {
        guard let tile = tile else { return false }

        return id == tile.id &&
        title == tile.title &&
        subtitle == tile.subtitle &&
        ranking == tile.ranking &&
        url == tile.url
    }
}

extension ShoppingTileEntity {
    static func mock(with context: NSManagedObjectContext) -> ShoppingTileEntity {
        let entity = ShoppingTileEntity(context: context)
        entity.id = UUID()
        entity.title = "Test title"
        entity.subtitle = "Test subtitle"
        entity.ranking = 50
        entity.cartItems = ["An item"]

        return entity
    }

    func isEqual(to tile: ShoppingTile?) -> Bool {
        guard let tile = tile else { return false }

        return id == tile.id &&
        title == tile.title &&
        subtitle == tile.subtitle &&
        ranking == tile.ranking &&
        cartItems == tile.cartItems
    }
}

//MARK: - Context

extension NSManagedObjectContext {
    static var mock: NSManagedObjectContext {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        } catch {
            print("Adding in-memory persistent store failed")
        }

        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator

        return managedObjectContext
    }
}
