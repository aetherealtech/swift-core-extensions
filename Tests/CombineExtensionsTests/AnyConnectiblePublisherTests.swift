import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class AnyConnectiblePublisherTests: XCTestCase {
    @MainActor
    func testAnyConnectiblePublisher() async throws {
        let publisher = (0..<100)
            .publisher
        
        let expectedValues = Array(0..<100)
        
        var receivedValuesInConnection: [Int] = []
        
        let connectiblePublisher = publisher
            .map { value in
                receivedValuesInConnection.append(value)
                return value
            }
            .buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest)
            .makeConnectable()
            .eraseToAnyConnectablePublisher()
        
        let connection = connectiblePublisher.connect()
        
        try assertEqual(expectedValues, receivedValuesInConnection)
        
        var receivedValues: [Int] = []
        
        let subscription = connectiblePublisher
            .sink { value in
                receivedValues.append(value)
            }
        
        try assertEqual(expectedValues, receivedValues)
        
        withExtendedLifetime(connection) {}
        withExtendedLifetime(subscription) {}
    }
}
