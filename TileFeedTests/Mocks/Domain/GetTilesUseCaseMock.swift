//
//  GetTilesUseCaseMock.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import Combine
@testable import TileFeed

final class GetTilesUseCaseMock: BaseMock {
    var result: Any?
}

extension GetTilesUseCaseMock: GetTilesUseCase {
    func execute() -> AnyPublisher<[Tile], Error> {
        mockPublisherResult()
    }
}
