//
//  TileListViewModelIntegrationTests.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 9/8/22.
//

import Combine
import CoreData
import XCTest
@testable import TileFeed

class TileListViewModelIntegrationTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    private let alamofireDataSource = AlamofireDataSourceMock()
    private lazy var coreDataSource = CoreDataSourceMock(context: NSManagedObjectContext.mock)
    private lazy var userDefaults: UserDefaults = {
        let userDefaults = UserDefaults(suiteName: "TestDefaults")!
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        return userDefaults
    }()
    private lazy var viewModel = TileListViewModel(
        getTilesUC: GetTilesUseCaseImpl(
            repository: TileRepositoryImpl(
                alamofireDataSource: alamofireDataSource,
                coreDataSource: coreDataSource,
                userDefaults: userDefaults
            )
        )
    )

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
    }

    func testFetchTilesSuccess() {
        //Given
        let dataSourceResult = TileRequest.Response.Tiles(tiles: [
            TileRequest.Response.mockImageTile,
            TileRequest.Response.mockShoppingTile
        ])
        alamofireDataSource.result = dataSourceResult
        var result = [TileListViewModel.ViewOutput]()
        let expectation = self.expectation(description: "success")

        //When
        viewModel
            .output
            .sink(
                receiveValue: {
                    result.append($0)
                    if $0 != .loading { expectation.fulfill() }
                }
            )
            .store(in: &cancellables)

        viewModel.input(.fetchTiles)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertEqual(result, [.loading, .ready])
        XCTAssertEqual(viewModel.tileList.count, dataSourceResult.tiles.count)
    }

    func testFetchTilesFailure() {
        //Given
        alamofireDataSource.result = BasicError(message: "")
        let expectation = self.expectation(description: "failure")
        var result = [TileListViewModel.ViewOutput]()

        //When
        viewModel
            .output
            .sink(
                receiveValue: {
                    result.append($0)
                    if $0 != .loading { expectation.fulfill() }
                }
            )
            .store(in: &cancellables)

        viewModel.input(.fetchTiles)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertEqual(result, [.loading, .ready])
        XCTAssertTrue(viewModel.tileList.isEmpty)
    }

}
