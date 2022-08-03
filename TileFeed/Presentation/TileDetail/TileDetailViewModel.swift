//
//  TileDetailViewModel.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import Combine

final class TileDetailViewModel: BaseViewModel {
    @Published var tile: Tile
    let output = PassthroughSubject<ViewOutput, Never>()

    private weak var onTileChanged: PassthroughSubject<Tile, Never>?
    private let addCartItemUC: AddCartItemUseCase
    private lazy var cancellables = Set<AnyCancellable>()

    init(tile: Tile, addCartItemUC: AddCartItemUseCase, onTileChanged: PassthroughSubject<Tile, Never>?) {
        self.tile = tile
        self.addCartItemUC = addCartItemUC
        self.onTileChanged = onTileChanged
    }

    deinit {
        cancellables.removeAll()
    }
}

//MARK: - View Comunication

extension TileDetailViewModel {
    func input(_ input: ViewInput) {
        switch input {
        case .addCartItem(let value) where tile is ShoppingTile:
            addCartItem(value)
            
        default:
            break
        }
    }

    enum ViewInput {
        case addCartItem(String)
    }

    enum ViewOutput {
        case error
    }
}

//MARK: - Private methods

private extension TileDetailViewModel {
    func addCartItem(_ cartItem: String) {
        guard var shoppingTile = tile as? ShoppingTile else { return }

        addCartItemUC
            .execute(cartItem: cartItem, tile: shoppingTile)
            .subscribe(on: .global)
            .receive(on: .main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.output.send(.error)
                    }
                }, receiveValue: { [weak self] cartItems in
                    shoppingTile.cartItems = cartItems
                    self?.tile = shoppingTile
                    self?.onTileChanged?.send(shoppingTile)
                }
            )
            .store(in: &cancellables)
    }
}

