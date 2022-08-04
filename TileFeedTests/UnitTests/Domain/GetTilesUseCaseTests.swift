//
//  GetTilesUseCaseTests.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import Combine
import XCTest
@testable import TileFeed

class GetTilesUseCaseTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    private let repository = TileRepositoryMock()
    private lazy var useCase = GetTilesUseCaseImpl(repository: repository)

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
    }

    //No refresh date - remote ok - save ok
    func testFetchRemoteTilesSuccess() {
        //Given
        let expectedResult: [Tile] = [URLTile.mock, ShoppingTile.mock]
        repository.resultDict = [
            .getDate: nil,
            .fetchRemote: expectedResult,
            .saveTiles: expectedResult
        ]
        let expectation = self.expectation(description: "success")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertNil(error)
        XCTAssertEqual(result!.count, expectedResult.count)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertTrue(repository.fetchRemoteCalled)
        XCTAssertFalse(repository.fetchLocalCalled)
        XCTAssertTrue(repository.saveTilesCalled)
        XCTAssertTrue(repository.updateDateCalled)
    }

    //No refresh date - remote ok - save ko
    func testFetchRemoteTilesSaveFailure() {
        //Given
        let expectedResult: [Tile] = [URLTile.mock, ShoppingTile.mock]
        repository.resultDict = [
            .getDate: nil,
            .fetchRemote: expectedResult,
            .saveTiles: BasicError(message: "")
        ]
        let expectation = self.expectation(description: "success")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertNil(error)
        XCTAssertEqual(result!.count, expectedResult.count)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertTrue(repository.fetchRemoteCalled)
        XCTAssertFalse(repository.fetchLocalCalled)
        XCTAssertTrue(repository.saveTilesCalled)
        XCTAssertFalse(repository.updateDateCalled)

    }

    //No refresh date - remote ko - local ok
    func testFetchRemoteTilesFailureLocalSuccess() {
        //Given
        let expectedResult: [Tile] = [URLTile.mock, ShoppingTile.mock]
        repository.resultDict = [
            .getDate: nil,
            .fetchRemote: BasicError(message: ""),
            .fetchLocal: expectedResult
        ]
        let expectation = self.expectation(description: "success")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertNil(error)
        XCTAssertEqual(result!.count, expectedResult.count)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertTrue(repository.fetchRemoteCalled)
        XCTAssertTrue(repository.fetchLocalCalled)
        XCTAssertFalse(repository.saveTilesCalled)
        XCTAssertFalse(repository.updateDateCalled)
    }

    //No refresh date - remote ko - local ko
    func testFetchTilesFailure() {
        //Given
        repository.resultDict = [
            .getDate: nil,
            .fetchRemote: BasicError(message: ""),
            .fetchLocal: BasicError(message: "")
        ]
        let expectation = self.expectation(description: "failure")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertTrue(repository.fetchRemoteCalled)
        XCTAssertTrue(repository.fetchLocalCalled)
        XCTAssertFalse(repository.saveTilesCalled)
        XCTAssertFalse(repository.updateDateCalled)
    }

    //Refresh date today - local ok
    func testFetchLocalTilesSuccess() {
        //Given
        let expectedResult: [Tile] = [URLTile.mock, ShoppingTile.mock]
        repository.resultDict = [
            .getDate: Date.today,
            .fetchLocal: expectedResult
        ]
        let expectation = self.expectation(description: "success")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, expectedResult.count)
        XCTAssertNil(error)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertFalse(repository.fetchRemoteCalled)
        XCTAssertTrue(repository.fetchLocalCalled)
        XCTAssertFalse(repository.saveTilesCalled)
        XCTAssertFalse(repository.updateDateCalled)
    }

    //Refresh date today - local ko
    func testFetchLocalFailure() {
        //Given
        repository.resultDict = [
            .getDate: Date.today,
            .fetchLocal: BasicError(message: "")
        ]
        let expectation = self.expectation(description: "failure")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertFalse(repository.fetchRemoteCalled)
        XCTAssertTrue(repository.fetchLocalCalled)
        XCTAssertFalse(repository.saveTilesCalled)
        XCTAssertFalse(repository.updateDateCalled)
    }

    //Refresh date yesterday - remote ok - save ok
    func testRefreshTilesSuccess() {
        //Given
        let expectedResult: [Tile] = [URLTile.mock, ShoppingTile.mock]
        repository.resultDict = [
            .getDate: Date.yesterday,
            .fetchRemote: expectedResult,
            .saveTiles: expectedResult
        ]
        let expectation = self.expectation(description: "success")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, expectedResult.count)
        XCTAssertNil(error)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertTrue(repository.fetchRemoteCalled)
        XCTAssertFalse(repository.fetchLocalCalled)
        XCTAssertTrue(repository.saveTilesCalled)
        XCTAssertTrue(repository.updateDateCalled)
    }

    //Refresh date yesterday - remote ok - save ko
    func testRefreshTilesSaveFailure() {
        //Given
        let expectedResult: [Tile] = [URLTile.mock, ShoppingTile.mock]
        repository.resultDict = [
            .getDate: Date.yesterday,
            .fetchRemote: expectedResult,
            .saveTiles: BasicError(message: "")
        ]
        let expectation = self.expectation(description: "success")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, expectedResult.count)
        XCTAssertNil(error)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertTrue(repository.fetchRemoteCalled)
        XCTAssertFalse(repository.fetchLocalCalled)
        XCTAssertTrue(repository.saveTilesCalled)
        XCTAssertFalse(repository.updateDateCalled)
    }

    //Refresh date yesterday - remote ko - local ok
    func testRefreshTilesRemoteFailureLocalSuccess() {
        //Given
        let expectedResult: [Tile] = [URLTile.mock, ShoppingTile.mock]
        repository.resultDict = [
            .getDate: Date.yesterday,
            .fetchRemote: BasicError(message: ""),
            .fetchLocal: expectedResult
        ]
        let expectation = self.expectation(description: "success")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, expectedResult.count)
        XCTAssertNil(error)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertTrue(repository.fetchRemoteCalled)
        XCTAssertTrue(repository.fetchLocalCalled)
        XCTAssertFalse(repository.saveTilesCalled)
        XCTAssertFalse(repository.updateDateCalled)
    }


    //Refresh date yesterday - remote ko - local ko
    func testRefreshTilesFailure() {
        //Given
        repository.resultDict = [
            .getDate: Date.yesterday,
            .fetchRemote: BasicError(message: ""),
            .fetchLocal: BasicError(message: "")
        ]
        let expectation = self.expectation(description: "failure")
        var result: [Tile]?
        var error: Error?

        //When
        useCase
            .execute()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertTrue(repository.getDateCalled)
        XCTAssertTrue(repository.fetchRemoteCalled)
        XCTAssertTrue(repository.fetchLocalCalled)
        XCTAssertFalse(repository.saveTilesCalled)
        XCTAssertFalse(repository.updateDateCalled)
    }

}
