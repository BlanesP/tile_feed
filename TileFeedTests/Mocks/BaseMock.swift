//
//  BaseMock.swift
//  TileFeedTests
//
//  Created by Pau Blanes on 2/8/22.
//

import Combine
@testable import TileFeed

protocol BaseMock {
    var result: Any? { get set }
}

extension BaseMock {
    func mockResult<T>() throws -> T {
        guard let result = result as? T else {
            let error = (result as? Error) ?? BasicError(message: "Mock error: Result not found or cast failed")
            throw error
        }

        return result
    }

    func mockPublisherResult<T>() -> AnyPublisher<T, Error> {
        guard let result = result as? T else {
            return Fail(error: (result as? Error) ?? BasicError(message: "Mock error: Result not found or cast failed"))
                .eraseToAnyPublisher()
        }

        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
