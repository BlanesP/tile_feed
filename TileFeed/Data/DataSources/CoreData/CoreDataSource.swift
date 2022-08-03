//
//  CoreDataSource.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import Combine
import CoreData

protocol CoreDataSource {
    func fetchAllTiles() -> AnyPublisher<[TileEntity], Error>
    func regenerateTiles(action: @escaping (NSManagedObjectContext) -> Void) -> AnyPublisher<Void, Error> 
    func updateTile<T: TileEntity>(request: NSFetchRequest<T>, action: @escaping (T) -> Void) -> AnyPublisher<T, Error>
}

final class CoreDataSourceImpl: Logger {

    let container: NSPersistentContainer

    init(inMemory: Bool = false, name: String = "Main") {
        container = NSPersistentContainer(name: name)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension CoreDataSourceImpl: CoreDataSource {
    func fetchAllTiles() -> AnyPublisher<[TileEntity], Error> {
        log("Fetching all tiles...")

        return asyncPublisher { backgroundContext, promise in
            let entities = try backgroundContext.fetch(TileEntity.fetchRequest())
            
            promise(.success(entities))
        }
    }

    func regenerateTiles(action: @escaping (NSManagedObjectContext) -> Void) -> AnyPublisher<Void, Error>  {
        log("Regenerating tiles...")

        return asyncPublisher { backgroundContext, promise in
            try backgroundContext.execute(
                NSBatchDeleteRequest(fetchRequest: TileEntity.fetchRequest())
            )

            action(backgroundContext)
            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }

            promise(.success(()))
        }
    }

    func updateTile<T: TileEntity>(request: NSFetchRequest<T>, action: @escaping (T) -> Void) -> AnyPublisher<T, Error> {
        log("Updating tiles...")

        return asyncPublisher { backgroundContext, promise in
            let entities = try backgroundContext.fetch(request)
            guard let entity = entities.first else {
                throw BasicError(message: "Failed to fetch tile")
            }

            action(entity)
            if backgroundContext.hasChanges {
                try backgroundContext.save()
            }

            promise(.success(entity))
        }
    }
}

//MARK: - Utils

private extension CoreDataSourceImpl {
    func asyncPublisher<T>(
        perform: @escaping (NSManagedObjectContext, Future<T, Error>.Promise) throws -> Void
    ) -> AnyPublisher<T, Error> {
        Deferred {
            Future { [weak self] promise in
                guard let container = self?.container else {
                    promise(.failure(BasicError(message: "CoreDataSource memory error")))
                    return
                }

                container.performBackgroundTask { backgroundContext in
                    do {
                        try perform(backgroundContext, promise)
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
