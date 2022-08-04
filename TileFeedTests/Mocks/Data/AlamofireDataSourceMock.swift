//
//  AlamofireDataSourceMock.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 2/8/22.
//

import Combine
@testable import TileFeed

final class AlamofireDataSourceMock: BaseMock {
    var result: Any?
}

extension AlamofireDataSourceMock: AlamofireDataSource {
    func requestTiles() -> AnyPublisher<TileRequest.Response.Tiles, Error> {
        mockPublisherResult()
    }
}
