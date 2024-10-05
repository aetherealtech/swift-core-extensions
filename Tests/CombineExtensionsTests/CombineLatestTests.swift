import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class CombineLatestTests: XCTestCase {
    struct ErrorWithPayload: Error {
        let payload: Int
    }
    
    @MainActor
    func testCombineLatestNoThrows() async throws {
        let publishers = (0..<10)
            .map { index in
                PassthroughSubject<Int, Never>()
            }
        
        let combinedPublisher = publishers
            .combineLatest()
        
        var receivedValues: [[Int]] = []
        
        let subscription = combinedPublisher
            .sink { value in
                receivedValues.append(value)
            }
        
        var currentValue = Array(0..<10)
        var expectedValues: [[Int]] = []
        
        for (index, publisher) in publishers.enumerated() {
            publisher.send(index)
            
            if index == publishers.indices.last {
                expectedValues.append(currentValue)
            }
            
            try assertEqual(expectedValues, receivedValues)
        }
        
        for _ in 0..<100 {
            let index = publishers.indices.randomElement()!
            let publisher = publishers[index]
            
            let nextValue = index * 2
            
            publisher.send(nextValue)
            currentValue[index] = nextValue
            
            expectedValues.append(currentValue)
            try assertEqual(expectedValues, receivedValues)
        }
        
        withExtendedLifetime(subscription) {}
    }
    
    @MainActor
    func testCombineLatestThrows() async throws {
        let publishers = (0..<10)
            .map { index in
                PassthroughSubject<Int, ErrorWithPayload>()
            }
        
        let combinedPublisher = publishers
            .combineLatest()
        
        var receivedValues: [[Int]] = []
        var receivedError: ErrorWithPayload?
        
        let subscription = combinedPublisher
            .sink { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
            } receiveValue: { value in
                receivedValues.append(value)
            }
        
        var currentValue = Array(0..<10)
        var expectedValues: [[Int]] = []
        
        for (index, publisher) in publishers.enumerated() {
            publisher.send(index)
            
            if index == publishers.indices.last {
                expectedValues.append(currentValue)
            }
            
            try assertEqual(expectedValues, receivedValues)
        }
        
        let errorPayload = Int.random(in: 10..<100)
        
        for _ in 0..<100 {
            let index = publishers.indices.randomElement()!
            let publisher = publishers[index]
            
            if receivedValues.count == 50 {
                publisher.send(completion: .failure(.init(payload: errorPayload)))
                break
            }
            
            let nextValue = index * 2
            
            publisher.send(nextValue)
            currentValue[index] = nextValue
            
            expectedValues.append(currentValue)
            try assertEqual(expectedValues, receivedValues)
        }
        
        try assertEqual(errorPayload, receivedError?.payload)
        
        withExtendedLifetime(subscription) {}
    }
    
    @MainActor
    func testCombineLatestComplete() async throws {
        let publishers = (0..<10)
            .map { index in
                (0..<10).publisher
            }
        
        let combinedPublisher = publishers
            .combineLatest()
        
        var receivedValues: [[Int]] = []
        var receivedValuesOnCompletion: [[Int]]?
        
        let subscription = combinedPublisher
            .sink { completion in
                receivedValuesOnCompletion = receivedValues
            } receiveValue: { value in
                receivedValues.append(value)
            }
        
        try assertEqual((0..<10).map { last in (0..<10).map { index in index == publishers.indices.last ? last : 9 } }, receivedValues)
        try assertEqual(receivedValues, receivedValuesOnCompletion)
        
        withExtendedLifetime(subscription) {}
    }
    
    @MainActor
    func testCombineLatestNoDemand() async throws {
        let publishers = (0..<10)
            .map { index in
                PassthroughSubject<Int, Never>()
            }
        
        let combinedPublisher = publishers
            .combineLatest()
        
        let subscriber = combinedPublisher.subscribeNoDemand()
        
        for (index, publisher) in publishers.enumerated() {
            publisher.send(index)
        }
                
        for _ in 0..<100 {
            let index = publishers.indices.randomElement()!
            let publisher = publishers[index]
     
            let nextValue = index * 2
            
            publisher.send(nextValue)
        }
        
        try assertEqual([], subscriber.received)
    }
}
