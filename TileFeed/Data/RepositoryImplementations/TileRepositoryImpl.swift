//
//  TileRepositoryImpl.swift
//  TileFeed
//
//  Created by Pau Blanes on 28/7/22.
//

import Combine
import Foundation
import CoreData

private extension String {
    static var lastRefreshDateKey: Self { "updateDate" }
}

final class TileRepositoryImpl: Logger {
    let alamofireDataSource: AlamofireDataSource
    let coreDataSource: CoreDataSource
    let userDefaults: UserDefaults

    init(alamofireDataSource: AlamofireDataSource, coreDataSource: CoreDataSource, userDefaults: UserDefaults) {
        self.alamofireDataSource = alamofireDataSource
        self.coreDataSource = coreDataSource
        self.userDefaults = userDefaults
    }
}

extension TileRepositoryImpl: TileRepository {
    //MARK: Date
    func updateLastRefreshDate(to date: Date) {
        log("Saving refresh date...")

        return userDefaults.set(date, forKey: .lastRefreshDateKey)
    }

    func getLastRefreshDate() -> Date? {
        log("Getting refresh date...")

        return userDefaults.object(forKey: .lastRefreshDateKey) as? Date
    }

    //MARK: Tiles
    func fetchTiles(refresh: Bool) -> AnyPublisher<[Tile], Error> {
        refresh ? fetchRemoteTiles() : fetchLocalTiles()
    }

    func saveTiles(_ tiles: [Tile]) -> AnyPublisher<[Tile], Error> {
        log("Saving tiles...")

        return coreDataSource
            .regenerateTiles() { context in
                for tile in tiles {
                    switch tile {
                    case is ShoppingTile:
                        let entity = ShoppingTileEntity(context: context)
                        entity.title = tile.title
                        entity.subtitle = tile.subtitle
                        entity.ranking = Int64(tile.ranking)
                        entity.id = tile.id
                        entity.cartItems = (tile as! ShoppingTile).cartItems

                    case is URLTile:
                        let entity: URLTileEntity = URLTileEntity(context: context)
                        entity.title = tile.title
                        entity.subtitle = tile.subtitle
                        entity.ranking = Int64(tile.ranking)
                        entity.id = tile.id
                        entity.url = (tile as! URLTile).url
                        entity.type = Int64((tile as! URLTile).type.rawValue)

                    default:
                        break
                    }
                }
            }
            .map { tiles }
            .eraseToAnyPublisher()
    }

    func addCartItem(_ item: String, to tileId: UUID) -> AnyPublisher<ShoppingTile, Error> {
        log("Adding cart item...")

        guard !item.isEmpty else {
            return Fail(error: BasicError(message: "Empty item")).eraseToAnyPublisher()
        }

        let request: NSFetchRequest<ShoppingTileEntity> = ShoppingTileEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tileId as NSUUID)

        return coreDataSource
            .updateTile(request: request, action: { entity in
                var items = entity.cartItems ?? []
                items.insert(item, at: 0)
                entity.cartItems = items
            })
            .tryMap { try ShoppingTile(from: $0) }
            .eraseToAnyPublisher()
    }
}

//MARK: - Utils

private extension TileRepositoryImpl {
    func fetchRemoteTiles() -> AnyPublisher<[Tile], Error> {
        log("Fetching remote tiles...")

        return alamofireDataSource
            .requestTiles()
            .map {
                $0.tiles.compactMap {
                    switch $0.name {
                    case "shopping_list":
                        return ShoppingTile(from: $0)
                    default:
                        return try? URLTile(from: $0)
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    func fetchLocalTiles() -> AnyPublisher<[Tile], Error> {
        log("Fetching local tiles...")

        return coreDataSource
            .fetchAllTiles()
            .map {
                $0.compactMap { entity in
                    switch entity {
                    case is ShoppingTileEntity:
                        return try? ShoppingTile(from: entity as! ShoppingTileEntity)
                    case is URLTileEntity:
                        return try? URLTile(from: entity as! URLTileEntity)
                    default:
                        return nil
                    }
                }
            }
            .eraseToAnyPublisher()
    }
}

//MARK: - Mappers

private extension URLTile {
    init(from response: TileRequest.Response.Tile) throws {
        guard let data = response.data, let url = URL(string: data) else {
            throw BasicError(message: "Data parsing error")
        }
        self.type = try URLType(name: response.name)
        self.url = url

        self.id = UUID()
        self.title = response.headline
        self.subtitle = response.subline
        self.ranking = response.score
    }

    init(from entity: URLTileEntity) throws {
        guard let url = entity.url, let type = URLType(rawValue: Int(entity.type)),
              let id = entity.id
        else {
            throw BasicError(message: "URLTileEntity parsing error")
        }
        self.type = type
        self.url = url

        self.id = id
        self.title = entity.title
        self.subtitle = entity.subtitle
        self.ranking = Int(entity.ranking)
    }
}

private extension URLTile.URLType {
    init(name: String) throws {
        switch name {
        case "image":
            self = .image

        case "video":
            self = .video

        case "website":
            self = .website

        default:
            throw BasicError(message: "Undefined tile type")
        }
    }
}

private extension ShoppingTile {
    init(from response: TileRequest.Response.Tile) {
        self.cartItems = [String]()

        self.id = UUID()
        self.title = response.headline
        self.subtitle = response.subline
        self.ranking = response.score
    }

    init(from entity: ShoppingTileEntity) throws {
        guard let cartItems = entity.cartItems,
              let id = entity.id
        else {
            throw BasicError(message: "ShoppingTileEntity parsing error")
        }
        self.cartItems = cartItems

        self.id = id
        self.title = entity.title
        self.subtitle = entity.subtitle
        self.ranking = Int(entity.ranking)
    }
}
