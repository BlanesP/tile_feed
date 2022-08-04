//
//  AddCartItemUseCase.swift
//  TileFeed
//
//  Created by Pau Blanes on 31/7/22.
//

import Combine
import Foundation

protocol AddCartItemUseCase {
    func execute(cartItem: String, tileId: UUID) -> AnyPublisher<ShoppingTile, Error>
}

final class AddCartItemUseCaseImpl: Logger {
    let repository: TileRepository

    init(repository: TileRepository) {
        self.repository = repository
    }
}

extension AddCartItemUseCaseImpl: AddCartItemUseCase {
    func execute(cartItem: String, tileId: UUID) -> AnyPublisher<ShoppingTile, Error> {
        log("Executing UseCase...")

        return repository.addCartItem(cartItem, to: tileId)
    }
}
