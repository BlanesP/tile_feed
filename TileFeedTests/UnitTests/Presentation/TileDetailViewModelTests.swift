//
//  TileDetailViewModelTests.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import Combine
import XCTest
@testable import TileFeed

class TileDetailViewModelTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    private let useCase = AddCartItemUseCaseMock()
    private lazy var viewModel = TileDetailViewModel(
        tile: ShoppingTile.mock,
        addCartItemUC: useCase,
        onTileChanged: nil
    )

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
    }

    func testAddCartItemSuccess() async throws {
        //Given
        let newItem = "New item"
        var expectedResult = ShoppingTile.mock
        expectedResult.cartItems.append(newItem)
        useCase.result = expectedResult

        //When
        viewModel.input(.addCartItem(newItem))

        try await Task.sleep(nanoseconds: UInt64(0.1 * Double(NSEC_PER_SEC)))

        //Then
        XCTAssertTrue((viewModel.tile as! ShoppingTile).cartItems.contains(newItem))
    }

    func testAddCartItemFailure() {
        //Given
        useCase.result = BasicError(message: "")
        let expectation = self.expectation(description: "failure")
        var result: TileDetailViewModel.ViewOutput?

        //When
        viewModel
            .output
            .sink(
                receiveValue: { result = $0; expectation.fulfill() }
            )
            .store(in: &cancellables)

        viewModel.input(.addCartItem("Test item"))

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertEqual(result, .error)
    }
}
