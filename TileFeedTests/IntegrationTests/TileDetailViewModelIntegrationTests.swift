//
//  TileDetailViewModelIntegrationTests.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 9/8/22.
//

import Combine
import CoreData
import XCTest
@testable import TileFeed

class TileDetailViewModelIntegrationTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    private let alamofireDataSource = AlamofireDataSourceMock()
    private let context = NSManagedObjectContext.mock
    private lazy var coreDataSource = CoreDataSourceMock(context: context)
    private lazy var userDefaults: UserDefaults = {
        let userDefaults = UserDefaults(suiteName: "TestDefaults")!
        userDefaults.removePersistentDomain(forName: "TestDefaults")
        return userDefaults
    }()
    private lazy var viewModel = TileDetailViewModel(
        tile: ShoppingTile.mock,
        addCartItemUC: AddCartItemUseCaseImpl(
            repository: TileRepositoryImpl(
                alamofireDataSource: alamofireDataSource,
                coreDataSource: coreDataSource,
                userDefaults: userDefaults
            )
        ),
        onTileChanged: nil
    )

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
    }

    func testAddCartItemSuccess() async throws {
        //Given
        let newItem = "New item"
        let fetchedEntity = ShoppingTileEntity.mock(with: context)
        coreDataSource.actionParams = fetchedEntity
        coreDataSource.result = fetchedEntity
        XCTAssertFalse((viewModel.tile as! ShoppingTile).cartItems.contains(newItem))

        //When
        viewModel.input(.addCartItem(newItem))

        try await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))

        //Then
        XCTAssertTrue((viewModel.tile as! ShoppingTile).cartItems.contains(newItem))
    }

    func testAddCartItemFailure() {
        //Given
        let newItem = "New item"
        coreDataSource.result = BasicError(message: "")
        let expectation = self.expectation(description: "failure")
        var result: TileDetailViewModel.ViewOutput?

        //When
        viewModel
            .output
            .sink(
                receiveValue: { result = $0; expectation.fulfill() }
            )
            .store(in: &cancellables)

        viewModel.input(.addCartItem(newItem))

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertEqual(result, .error)
        XCTAssertFalse((viewModel.tile as! ShoppingTile).cartItems.contains(newItem))
    }

}
