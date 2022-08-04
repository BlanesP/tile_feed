//
//  ViewFactory.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import Combine
import SwiftUI

struct ViewFactory {
    static var homeView: some View {
        TileListView(
            viewModel: TileListViewModel(
                getTilesUC: DomainFactory.getTilesUC
            )
        )
    }

    static func tileDetailView(tile: Tile, onTileChangedd: PassthroughSubject<Tile, Never>? = nil) -> some View {
        TileDetailView(
            viewModel: TileDetailViewModel(
                tile: tile,
                addCartItemUC: DomainFactory.addCartItemUC,
                onTileChanged: onTileChangedd
            )
        )
    }
}

private extension ViewFactory {
    struct DomainFactory {
        //MARK: Repositories
        static var tileRepository: TileRepository {
            TileRepositoryImpl(
                alamofireDataSource: AlamofireDataSourceImpl(),
                coreDataSource: CoreDataSourceImpl(),
                userDefaults: UserDefaults.standard
            )
        }

        //MARK: UseCases
        static var getTilesUC: GetTilesUseCase {
            GetTilesUseCaseImpl(repository: tileRepository)
        }

        static var addCartItemUC: AddCartItemUseCase {
            AddCartItemUseCaseImpl(repository: tileRepository)
        }
    }
}
