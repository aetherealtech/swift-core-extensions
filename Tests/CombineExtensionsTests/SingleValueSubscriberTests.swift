import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SingleValueSubscriberTests: XCTestCase {
    @MainActor
    func testReceiveValue() async throws {
        let publisher = (35..<100)
            .publisher
                
        var receivedValues: [Int] = []
        
        publisher
            .subscribeNext { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
        
        let expectedValue = 35
        
        try assertEqual([expectedValue], receivedValues)
    }
    
    @MainActor
    func testReceiveThrowingValue() async throws {
        let publisher = (35..<100)
            .publisher
            .setFailureType(to: TestError.self)
                
        var receivedCompletion: Subscribers.Completion<TestError>?
        var receivedValues: [Int] = []
        
        publisher
            .subscribeNext { completion in
                MainActor.assumeIsolated {
                    receivedCompletion = completion
                }
            } receiveValue: { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
        
        let expectedValue = 35
        
        try assertEqual([expectedValue], receivedValues)
        try assertNil(receivedCompletion)
    }
    
    @MainActor
    func testReceiveCompletion() async throws {
        let publisher = Empty<Int, Never>(completeImmediately: true)
                        
        var receivedCompletion: Subscribers.Completion<Never>?
        var receivedValues: [Int] = []
        
        publisher
            .subscribeNext { completion in
                MainActor.assumeIsolated {
                    receivedCompletion = completion
                }
            } receiveValue: { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
        
        // Adds test coverage for the no-op `receiveCompletion` callback on the overload of `subscribeNext` that only takes `receiveValue`
        publisher
            .subscribeNext { _ in }
                
        try assertEqual(.finished, receivedCompletion)
        try assertTrue(receivedValues.isEmpty)
    }
    
    @MainActor
    func testCancelAfterSubscribing() async throws {
        let publisher = PassthroughSubject<Int, Never>()
                        
        var receivedCompletion: Subscribers.Completion<Never>?
        var receivedValues: [Int] = []
        
        let subscription = publisher
            .subscribeNext { completion in
                MainActor.assumeIsolated {
                    receivedCompletion = completion
                }
            } receiveValue: { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
        
        subscription.cancel()
        
        try assertNil(receivedCompletion)
        try assertTrue(receivedValues.isEmpty)
    }
    
    @MainActor
    func testCancelBeforeSubscribing() async throws {
        let publisher = PassthroughSubject<Int, Never>()
                        
        var receivedCompletion: Subscribers.Completion<Never>?
        var receivedValues: [Int] = []
        
        let subscription = SingleValueSubscriber(
            receiveValue: { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            },
            receiveCompletion: { completion in
                MainActor.assumeIsolated {
                    receivedCompletion = completion
                }
            }
        )
        
        subscription.cancel()
        
        publisher.receive(subscriber: subscription)
        
        try assertNil(receivedCompletion)
        try assertTrue(receivedValues.isEmpty)
    }
}
