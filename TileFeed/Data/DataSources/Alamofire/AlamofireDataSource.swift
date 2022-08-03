//
//  AlamofireDataSource.swift
//  TileFeed
//
//  Created by Pau Blanes on 28/7/22.
//

import Alamofire
import Combine

protocol AlamofireDataSource {
    func requestTiles() -> AnyPublisher<TileRequest.Response.Tiles, Error>
}

final class AlamofireDataSourceImpl: Logger { }

extension AlamofireDataSourceImpl: AlamofireDataSource {
    func requestTiles() -> AnyPublisher<TileRequest.Response.Tiles, Error> {
        log("Requesting tiles...")

        return AF.request(.tilesEndpoint, method: .get)
            .validate()
            .publishDecodable(type: TileRequest.Response.Tiles.self, queue: .global)
            .tryMap { response in
                switch response.result {
                case .failure(let error):
                    throw error
                case .success(let data):
                    return data
                }
            }
            .eraseToAnyPublisher()
    }
}
