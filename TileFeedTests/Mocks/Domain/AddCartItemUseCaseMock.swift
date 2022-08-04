//
//  AddCartItemUseCaseMock.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import Combine
import Foundation
@testable import TileFeed

final class AddCartItemUseCaseMock: BaseMock {
    var result: Any?
}

extension AddCartItemUseCaseMock: AddCartItemUseCase {
    func execute(cartItem: String, tileId: UUID) -> AnyPublisher<ShoppingTile, Error> {
        mockPublisherResult()
    }
}
