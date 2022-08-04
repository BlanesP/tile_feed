//
//  TileFeedTests.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 2/8/22.
//

import Combine
import CoreData
import XCTest
@testable import TileFeed

class TileRepositoryTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    private let context = NSManagedObjectContext.mock
    private let alamofireDataSource = AlamofireDataSourceMock()
    private lazy var coreDataSource = CoreDataSourceMock(context: context)
    private lazy var userDefaults: UserDefaults = {
        let userDefaults = UserDefaults(suiteName: "TestDefaults")!
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        return userDefaults
    }()
    private lazy var repository = TileRepositoryImpl(
        alamofireDataSource: alamofireDataSource,
        coreDataSource: coreDataSource,
        userDefaults: userDefaults
    )

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
    }

    //MARK: - Fetch Remote tiles

    func testFetchRemoteTilesSuccess() {
        //Given
        let dataSourceResult = TileRequest.Response.Tiles(tiles: [
            TileRequest.Response.mockImageTile,
            TileRequest.Response.mockShoppingTile
        ])
        alamofireDataSource.result = dataSourceResult
        var result: [Tile]?
        let expectation = self.expectation(description: "success")

        //When
        repository
            .fetchTiles(refresh: true)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, dataSourceResult.tiles.count)
        XCTAssertTrue(
            result![0] is URLTile
        )
        XCTAssertTrue(
            result![1] is ShoppingTile
        )
    }

    func testFetchRemoteTilesEmpty() {
        //Given
        let dataSourceResult = TileRequest.Response.Tiles(tiles: [])
        alamofireDataSource.result = dataSourceResult
        var result: [Tile]?
        let expectation = self.expectation(description: "empty")

        //When
        repository
            .fetchTiles(refresh: true)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.isEmpty)
    }

    func testFetchRemoteTilesFailure() {
        //Given
        alamofireDataSource.result = BasicError(message: "")
        var result: [Tile]?
        var error: BasicError?
        let expectation = self.expectation(description: "failure")

        //When
        repository
            .fetchTiles(refresh: true)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e as? BasicError
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
    }

    //MARK: - Fetch local tiles

    func testFetchLocalTilesSuccess() {
        //Given
        let dataSourceResult = [
            URLTileEntity.mock(with: context),
            ShoppingTileEntity.mock(with: context)
        ]
        coreDataSource.result = dataSourceResult
        var result: [Tile]?
        let expectation = self.expectation(description: "success")

        //When
        repository
            .fetchTiles(refresh: false)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, dataSourceResult.count)
        XCTAssertTrue(
            (dataSourceResult[0] as! URLTileEntity).isEqual(to: result?[0] as? URLTile)
        )
        XCTAssertTrue(
            (dataSourceResult[1] as! ShoppingTileEntity).isEqual(to: result?[1] as? ShoppingTile)
        )
    }

    func testFetchLocalTilesEmpty() {
        //Given
        coreDataSource.result = [TileEntity]()
        var result: [Tile]?
        let expectation = self.expectation(description: "empty")

        //When
        repository
            .fetchTiles(refresh: false)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.isEmpty)
    }

    func testFetchLocalTilesFailure() {
        //Given
        coreDataSource.result = BasicError(message: "")
        var result: [Tile]?
        var error: BasicError?
        let expectation = self.expectation(description: "failure")

        //When
        repository
            .fetchTiles(refresh: false)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e as? BasicError
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
    }

    //MARK: - Save tiles

    func testSaveTilesSuccess() {
        //Given
        let input: [Tile] = [URLTile.mock, ShoppingTile.mock]
        coreDataSource.result = ()
        let expectation = self.expectation(description: "success")
        var result: [Tile]?

        //When
        repository
            .saveTiles(input)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.count == input.count)

    }

    func testSaveTilesFailure() {
        //Given
        let input: [Tile] = [URLTile.mock, ShoppingTile.mock]
        coreDataSource.result = BasicError(message: "")
        let expectation = self.expectation(description: "failure")
        var result: [Tile]?
        var error: BasicError?

        //When
        repository
            .saveTiles(input)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e as? BasicError
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
    }

    //MARK: - Add Cart Item

    func testAddCartItemSuccess() {
        //Given
        let newItem = "New item"
        let fetchedEntity = ShoppingTileEntity.mock(with: context)
        coreDataSource.actionParams = fetchedEntity
        fetchedEntity.cartItems?.append(newItem)
        coreDataSource.result = fetchedEntity

        var result: ShoppingTile?
        let expectation = self.expectation(description: "success")

        //When
        repository
            .addCartItem(newItem, to: ShoppingTile.mock.id)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertTrue(coreDataSource.updateTileCalled)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.cartItems.contains(newItem))
    }

    func testAddCartItemEmpty() {
        //Given
        var result: ShoppingTile?
        var error: BasicError?
        let expectation = self.expectation(description: "failure")

        //When
        repository
            .addCartItem("", to: ShoppingTile.mock.id)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e as? BasicError
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertFalse(coreDataSource.updateTileCalled)
        XCTAssertNil(result)
        XCTAssertNotNil(error)
        XCTAssertEqual(error!.message, "Empty item")
    }

    func testAddCartItemFailure() {
        //Given
        coreDataSource.result = BasicError(message: "")
        var result: ShoppingTile?
        var error: BasicError?
        let expectation = self.expectation(description: "failure")

        //When
        repository
            .addCartItem("New item", to: ShoppingTile.mock.id)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let e) = completion {
                        error = e as? BasicError
                    }
                    expectation.fulfill()
                },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertTrue(coreDataSource.updateTileCalled)
        XCTAssertNil(result)
        XCTAssertNotNil(error)
    }

    //MARK: - Refresh date

    func testCreateRefreshDate() {
        //Given
        let expectedResult = Date.mockDate(from: "12/05/2022")
        XCTAssertNil(userDefaults.object(forKey: "updateDate") as? Date)

        //When
        repository.updateLastRefreshDate(to: expectedResult)

        //Then
        XCTAssertEqual(expectedResult, userDefaults.object(forKey: "updateDate") as! Date)
    }

    func testOverrideRefreshDate() {
        //Given
        let firstDate = Date.mockDate(from: "01/01/2022")
        userDefaults.set(firstDate, forKey: "updateDate")
        XCTAssertEqual(firstDate, userDefaults.object(forKey: "updateDate") as! Date)
        let expectedResult = Date.mockDate(from: "02/02/2022")

        //When
        repository.updateLastRefreshDate(to: expectedResult)

        //Then
        XCTAssertEqual(expectedResult, userDefaults.object(forKey: "updateDate") as! Date)
    }

    func testGetRefreshDateSuccess() {
        //Given
        let expectedResult = Date.mockDate(from: "10/03/2022")
        userDefaults.set(expectedResult, forKey: "updateDate")

        //When
        let result = repository.getLastRefreshDate()

        //Then
        XCTAssertEqual(result, expectedResult)
    }

    func testGetRefreshDateNoDate() {
        //Given

        //When
        let result = repository.getLastRefreshDate()

        //Then
        XCTAssertNil(result)
    }
}
