//
//  TileListViewModel.swift
//  TileFeed
//
//  Created by Pau Blanes on 28/7/22.
//

import Combine

final class TileListViewModel: BaseViewModel {

    @Published var tileList = [Tile]()
    let output = PassthroughSubject<ViewOutput, Never>()
    let onTileChanged = PassthroughSubject<Tile, Never>()

    private let getTilesUC: GetTilesUseCase
    private lazy var cancellables = Set<AnyCancellable>()

    init(getTilesUC: GetTilesUseCase) {
        self.getTilesUC = getTilesUC

        onTileChanged
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] newTile in
                    if let index = self?.tileList.firstIndex(where: { $0.id == newTile.id }) {
                        self?.update(tileIndex: index, to: newTile)
                    }
                }
            )
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }
}

//MARK: - View Comunication

extension TileListViewModel {
    func input(_ input: ViewInput) {
        switch input {
        case .fetchTiles:
            fetchTiles()
        }
    }

    enum ViewInput {
        case fetchTiles
    }

    enum ViewOutput {
        case loading
        case ready
    }
}

//MARK: - Private methods

private extension TileListViewModel {
    func fetchTiles() {
        output.send(.loading)

        getTilesUC
            .execute()
            .subscribe(on: .global)
            .receive(on: .main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.output.send(.ready) //In this case error is handled by empty state
                },
                receiveValue: { [weak self] tileList in
                    self?.tileList = tileList.sorted(by: { $0.ranking > $1.ranking })
                }
            )
            .store(in: &cancellables)
    }

    func update(tileIndex: Int, to newTile: Tile) {
        guard (0..<tileList.count).contains(tileIndex) else { return }
        tileList[tileIndex] = newTile
    }
}
