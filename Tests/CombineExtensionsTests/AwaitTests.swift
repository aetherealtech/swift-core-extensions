import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class AwaitTests: XCTestCase {
    @MainActor
    func testAwaitNoThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
            
            let jobs = (0..<10)
                .map { index in
                    { @Sendable @MainActor in
                        await withCheckedContinuation { continuation in
                            continuations.value[index] = continuation
                        }
                        
                        return index
                    }
                }
            
            let publisher = jobs.publisher
                .await()
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for try await receivedValues in receivedValues.values {
                    if receivedValues.contains(index) {
                        break
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testAwaitOuterThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
            
            let jobs = (0..<10)
                .map { index in
                    { @Sendable @MainActor in
                        await withCheckedContinuation { continuation in
                            continuations.value[index] = continuation
                        }
                        
                        return index
                    }
                }
            
            let publisher = jobs.publisher
                .setFailureType(to: TestError.self)
                .await()
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for try await receivedValues in receivedValues.values {
                    if receivedValues.contains(index) {
                        break
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testAwaitThrowingNoThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
            
            let jobs = (0..<10)
                .map { index in
                    { @Sendable @MainActor in
                        try await withCheckedThrowingContinuation { continuation in
                            continuations.value[index] = continuation
                        }
                        
                        return index
                    }
                }
            
            let publisher = jobs.publisher
                .await()
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for try await receivedValues in receivedValues.values {
                    if receivedValues.contains(index) {
                        break
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testAwaitThrowingThrows() async throws {
        try await withTimeout(timeInterval: 5.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
            
            let jobs = (0..<10)
                .map { index in
                    { @Sendable @MainActor in
                        try await withCheckedThrowingContinuation { continuation in
                            continuations.value[index] = continuation
                        }
                        
                        return index
                    }
                }
            
            let publisher = jobs.publisher
                .await()
            
            nonisolated(unsafe) let receivedCompletion = CurrentValueSubject<Subscribers.Completion<any Error>?, Never>(nil)
            
            let subscription = publisher
                .sink { @Sendable completion in
                    Task { @MainActor in
                        receivedCompletion.value = completion
                    }
                } receiveValue: { @Sendable _ in }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                if index == 5 {
                    allContinuations[index]!.resume(throwing: TestError())
                } else {
                    allContinuations[index]!.resume()
                }
            }
            
            for try await receivedCompletion in receivedCompletion.values {
                if let receivedCompletion {
                    guard case let .failure(error) = receivedCompletion else {
                        throw Fail("Expected publisher to fail")
                    }
                    
                    try assertTrue(error is TestError)
                    
                    break
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
}
