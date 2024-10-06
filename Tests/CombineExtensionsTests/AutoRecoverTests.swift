import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class AutoRecoverTests: XCTestCase {
    @MainActor
    func testAutoRecover() async throws {
        var currentPublisher: PassthroughSubject<Int, TestError>!
        
        let createPublisher: () -> PassthroughSubject<Int, TestError> = {
            currentPublisher = .init()
            return currentPublisher
        }
        
        let autoRecoverPublisher = autoRecover(publisher: createPublisher)
        
        var receivedValues: [Int] = []
        
        let subscription = autoRecoverPublisher
            .sink { value in
                receivedValues.append(value)
            }
        
        var expectedValues: [Int] = []
        
        for _ in 0..<20 {
            let next = Int.random(in: 10..<100)
            expectedValues.append(next)
            currentPublisher.send(next)
        }
        
        currentPublisher.send(completion: .failure(.init()))
        
        for _ in 0..<20 {
            let next = Int.random(in: 10..<100)
            expectedValues.append(next)
            currentPublisher.send(next)
        }
        
        try assertEqual(expectedValues, receivedValues)
        
        withExtendedLifetime(subscription) {}
    }
}
