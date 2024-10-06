import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class EraseErrorTypeTests: XCTestCase {
    @MainActor
    func testEraseErrorType() async throws {
        let publisher = PassthroughSubject<Int, ErrorWithPayload>()
        
        var receivedError: (any Error)?
        var receivedValues: [Int] = []
        
        let erasedErrorTypePublisher = publisher
            .eraseErrorType()
        
        let subscription = erasedErrorTypePublisher
            .sink { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
            } receiveValue: { value in
                receivedValues.append(value)
            }
        
        let expectedError = ErrorWithPayload(payload: .random(in: 20..<1000))
        var expectedValues: [Int] = []
        
        for _ in 0..<20 {
            let next = Int.random(in: 10..<100)
            expectedValues.append(next)
            publisher.send(next)
        }
        
        publisher.send(completion: .failure(expectedError))

        try assertEqual(expectedValues, receivedValues)
        try assertEqual(expectedError, receivedError as? ErrorWithPayload)
        
        withExtendedLifetime(subscription) {}
    }
}
