import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class UntilSubscriberTests: XCTestCase {
    @MainActor
    func testReceiveValue() async throws {
        let publisher = (35..<100)
            .publisher
                
        var receivedValues: [Int] = []
        
        publisher
            .subscribe { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            } until: { value in value == 75 }
        
        let expectedValues = Array(35...75)
        
        try assertEqual(expectedValues, receivedValues)
    }
    
    @MainActor
    func testReceiveThrowingValue() async throws {
        let publisher = (35..<100)
            .publisher
            .setFailureType(to: TestError.self)
                
        var receivedCompletion: Subscribers.Completion<TestError>?
        var receivedValues: [Int] = []
        
        publisher
            .subscribe { completion in
                MainActor.assumeIsolated {
                    receivedCompletion = completion
                }
            } receiveValue: { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            } until: { value in value == 75 }
        
        let expectedValues = Array(35...75)
        
        try assertEqual(expectedValues, receivedValues)
        try assertNil(receivedCompletion)
    }
    
    @MainActor
    func testReceiveCompletion() async throws {
        let publisher = Empty<Int, Never>(completeImmediately: true)
                        
        var receivedCompletion: Subscribers.Completion<Never>?
        var receivedValues: [Int] = []
        
        publisher
            .subscribe { completion in
                MainActor.assumeIsolated {
                    receivedCompletion = completion
                }
            } receiveValue: { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            } until: { value in value == 75 }
        
        // Adds test coverage for the no-op `receiveCompletion` callback on the overload of `subscribeNext` that only takes `receiveValue`
        publisher
            .subscribe { _ in } until: { _ in false }
                
        try assertEqual(.finished, receivedCompletion)
        try assertTrue(receivedValues.isEmpty)
    }
    
    @MainActor
    func testCancelAfterSubscribing() async throws {
        let publisher = PassthroughSubject<Int, Never>()
                        
        var receivedCompletion: Subscribers.Completion<Never>?
        var receivedValues: [Int] = []
        
        let subscription = publisher
            .subscribe { completion in
                MainActor.assumeIsolated {
                    receivedCompletion = completion
                }
            } receiveValue: { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            } until: { value in value == 75 }
        
        subscription.cancel()
        
        try assertNil(receivedCompletion)
        try assertTrue(receivedValues.isEmpty)
    }
    
    @MainActor
    func testCancelBeforeSubscribing() async throws {
        let publisher = PassthroughSubject<Int, Never>()
                        
        var receivedCompletion: Subscribers.Completion<Never>?
        var receivedValues: [Int] = []
        
        let subscription = UntilSubscriber(
            receiveValue: { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            },
            receiveCompletion: { completion in
                MainActor.assumeIsolated {
                    receivedCompletion = completion
                }
            },
            until: { value in value == 75 }
        )
        
        subscription.cancel()
        
        publisher.receive(subscriber: subscription)
        
        try assertNil(receivedCompletion)
        try assertTrue(receivedValues.isEmpty)
    }
}
