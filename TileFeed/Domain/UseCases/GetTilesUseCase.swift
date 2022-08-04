//
//  GetTilesUseCase.swift
//  TileFeed
//
//  Created by Pau Blanes on 29/7/22.
//

import Combine
import Foundation

protocol GetTilesUseCase {
    func execute() -> AnyPublisher<[Tile], Error>
}

final class GetTilesUseCaseImpl: Logger {
    let repository: TileRepository

    init(repository: TileRepository) {
        self.repository = repository
    }
}

extension GetTilesUseCaseImpl: GetTilesUseCase {
    func execute() -> AnyPublisher<[Tile], Error> {
        log("Executing UseCase...")

        return shouldRefresh ? refreshTiles() : repository.fetchTiles(refresh: false)
    }
}

//MARK: - Utils

private extension GetTilesUseCaseImpl {
    var shouldRefresh: Bool {
        guard let daysFromToday = repository.getLastRefreshDate()?.daysBetweenToday else {
            return true
        }
        return daysFromToday > 0
    }

    func refreshTiles() -> AnyPublisher<[Tile], Error> {
        repository
            .fetchTiles(refresh: true)
            .flatMap { [weak self] tiles -> AnyPublisher<[Tile], Error> in
                guard let repository = self?.repository else {
                    return Fail(error: BasicError(message: "Memory error in GetTilesUseCase"))
                        .eraseToAnyPublisher()
                }
                
                return repository
                    .saveTiles(tiles)
                    .handleEvents(
                        receiveCompletion: { completion in
                            if case .finished = completion {
                                repository.updateLastRefreshDate(to: .today)
                            }
                        }
                    )
                    .replaceError(with: tiles)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .catch { [weak self] error -> AnyPublisher<[Tile], Error> in
                guard let repository = self?.repository else {
                    return Fail(error: BasicError(message: "Memory error in GetTilesUseCase"))
                        .eraseToAnyPublisher()
                }
                
                return repository.fetchTiles(refresh: false)
            }
            .eraseToAnyPublisher()
    }
}
