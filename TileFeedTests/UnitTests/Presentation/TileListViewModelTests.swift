//
//  TileListViewModelTests.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import Combine
import XCTest
@testable import TileFeed

class TileListViewModelTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    private let useCase = GetTilesUseCaseMock()
    private lazy var viewModel = TileListViewModel(getTilesUC: useCase)

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
    }

    func testFetchTilesSuccess() {
        //Given
        let expectedResult: [Tile] = [URLTile.mock, ShoppingTile.mock]
        useCase.result = expectedResult
        let expectation = self.expectation(description: "success")
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
        XCTAssertEqual(viewModel.tileList.count, expectedResult.count)
    }

    func testFetchTilesFailure() {
        //Given
        useCase.result = BasicError(message: "")
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
