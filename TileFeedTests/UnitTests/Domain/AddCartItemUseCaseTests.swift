//
//  AddCartItemUseCaseTests.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 4/8/22.
//

import Combine
import XCTest
@testable import TileFeed

class AddCartItemUseCaseTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()
    private let repository = TileRepositoryMock()
    private lazy var useCase = AddCartItemUseCaseImpl(repository: repository)

    override func tearDown() {
        super.tearDown()
        cancellables.removeAll()
    }

    func testAddCartItemSuccess() {
        //Given
        repository.result = ShoppingTile.mock
        var result: ShoppingTile?
        let expectation = self.expectation(description: "success")

        //When
        useCase
            .execute(cartItem: "New item", tileId: UUID())
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { result = $0 }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 0.1)

        //Then
        XCTAssertNotNil(result)
    }

    func testAddCartItemFailure() {
        //Given
        repository.result = BasicError(message: "")
        var error: BasicError?
        var result: ShoppingTile?
        let expectation = self.expectation(description: "success")

        //When
        useCase
            .execute(cartItem: "New item", tileId: UUID())
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
        XCTAssertNotNil(error)
        XCTAssertNil(result)
    }
}
