//
//  AddCartItemUseCase.swift
//  TileFeed
//
//  Created by Pau Blanes on 31/7/22.
//

import Combine

protocol AddCartItemUseCase {
    func execute(cartItem: String, tile: ShoppingTile) -> AnyPublisher<[String], Error>
}

final class AddCartItemUseCaseImpl: Logger {
    let repository: TileRepository

    init(repository: TileRepository) {
        self.repository = repository
    }
}

extension AddCartItemUseCaseImpl: AddCartItemUseCase {
    func execute(cartItem: String, tile: ShoppingTile) -> AnyPublisher<[String], Error> {
        log("Executing UseCase...")

        return repository.addCartItem(cartItem, to: tile)
    }
}
