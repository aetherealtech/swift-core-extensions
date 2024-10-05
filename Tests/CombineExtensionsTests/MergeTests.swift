import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class MergeTests: XCTestCase {
    struct ErrorWithPayload: Error {
        let payload: Int
    }
    
    @MainActor
    func testMergeNoThrows() async throws {
        let publishers = (0..<10)
            .map { index in
                PassthroughSubject<Int, Never>()
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        
        let subscription = mergedPublisher
            .sink { value in
                receivedValues.append(value)
            }
        
        var expectedValues: [Int] = []
        
        for _ in 0..<100 {
            let index = publishers.indices.randomElement()!
            let publisher = publishers[index]
            
            let nextValue = index * 2
            
            publisher.send(nextValue)
            expectedValues.append(nextValue)
            
            try assertEqual(expectedValues, receivedValues)
        }
        
        withExtendedLifetime(subscription) {}
    }
    
    @MainActor
    func testMergeThrows() async throws {
        let publishers = (0..<10)
            .map { index in
                PassthroughSubject<Int, ErrorWithPayload>()
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        var receivedError: ErrorWithPayload?
        
        let subscription = mergedPublisher
            .sink { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                }
            } receiveValue: { value in
                receivedValues.append(value)
            }
        
        var expectedValues: [Int] = []

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
            expectedValues.append(nextValue)
            
            try assertEqual(expectedValues, receivedValues)
        }
        
        try assertEqual(errorPayload, receivedError?.payload)
        
        withExtendedLifetime(subscription) {}
    }
    
    @MainActor
    func testMergeComplete() async throws {
        let publishers = (0..<10)
            .map { index in
                (0..<10).publisher
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        var receivedValuesOnCompletion: [Int]?
        
        let subscription = mergedPublisher
            .sink { completion in
                receivedValuesOnCompletion = receivedValues
            } receiveValue: { value in
                receivedValues.append(value)
            }
        
        try assertEqual((0..<10).flatMap { _ in (0..<10) }, receivedValues)
        try assertEqual(receivedValues, receivedValuesOnCompletion)
        
        withExtendedLifetime(subscription) {}
    }
    
    @MainActor
    func testMergeNoDemand() async throws {
        let publishers = (0..<10)
            .map { index in
                PassthroughSubject<Int, Never>()
            }
        
        let mergedPublisher = publishers
            .merge()
        
        let subscriber = mergedPublisher.subscribeNoDemand()
        
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
    
    @MainActor
    func testMergeOnDemand() async throws {
        let publishers = (0..<10)
            .map { index in
                (0..<10).publisher.print("PUB \(index)")
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        
        for await value in mergedPublisher.print("MERGED").values {
            receivedValues.append(value)
        }
        
        try assertEqual((0..<10).flatMap { _ in (0..<10) }, receivedValues)
    }
    
    @MainActor
    func testMergeDelayedUnlimitedDemand() async throws {
        let publishers = (0..<10)
            .map { index in
                (0..<10).publisher.print("PUB \(index)")
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        
        let subscriber = mergedPublisher
            .subscribeManualDemand { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
        
        subscriber.request(demand: .unlimited)
 
        try assertEqual(Array(Array(repeating: 0, count: 10)).appending(contentsOf: (0..<10).flatMap { _ in (1..<10) }), receivedValues)
    }
    
    @MainActor
    func testMergeDelayedFiniteSynchronousDemand() async throws {
        let publishers = (0..<10)
            .map { index in
                (0..<10).publisher.print("PUB \(index)")
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        
        let subscriber = mergedPublisher
            .subscribeManualDemand { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
        
        subscriber.extraDemand = .max(1)
        
        subscriber.request(demand: .unlimited)
 
        try assertEqual(Array(Array(repeating: 0, count: 10)).appending(contentsOf: (0..<10).flatMap { _ in (1..<10) }), receivedValues)
    }
    
    @MainActor
    func testMergeDelayedUnlimitedSynchronousDemand() async throws {
        let publishers = (0..<10)
            .map { index in
                (0..<10).publisher.print("PUB \(index)")
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        
        let subscriber = mergedPublisher
            .subscribeManualDemand { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
        
        subscriber.extraDemand = .unlimited
        
        subscriber.request(demand: .max(1))
 
        try assertEqual(Array(Array(repeating: 0, count: 10)).appending(contentsOf: (0..<10).flatMap { _ in (1..<10) }), receivedValues)
    }

    @MainActor
    func testMergeCancel() async throws {
        let publishers = (0..<10)
            .map { index in
                (0..<10).publisher.print("PUB \(index)")
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        
        let subscriber = mergedPublisher
            .print("MERGED")
            .subscribeManualDemand { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
                
        subscriber.request(demand: .max(50))
        
        subscriber.cancel()
 
        try assertEqual((0..<5).flatMap { value in Array(repeating: value, count: 10) }, receivedValues)
    }
    
    @MainActor
    func testMergeCancelPartialSubscribers() async throws {
        let publishers = (0..<10)
            .map { index in
                PassthroughSubject<Int, Never>()
            }
        
        let mergedPublisher = publishers
            .merge()
        
        var receivedValues: [Int] = []
        
        let subscriber = mergedPublisher
            .print("MERGED")
            .subscribeManualDemand { value in
                MainActor.assumeIsolated {
                    receivedValues.append(value)
                }
            }
        
        for publisher in publishers {
            publisher.send(0)
        }
                
        subscriber.request(demand: .max(50))
        
        for index in 5..<10 {
            publishers[index].send(completion: .finished)
        }
        
        for index in 0..<5 {
            publishers[index].send(1)
        }
        
        subscriber.cancel()
 
        try assertEqual(Array(repeating: 0, count: 10).appending(contentsOf: Array(repeating: 1, count: 5)), receivedValues)
    }
}
