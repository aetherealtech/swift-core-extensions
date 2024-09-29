import AsyncExtensions
import Assertions
import Combine
import XCTest

@testable import AsyncCollectionExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class AsyncCollectionTests: XCTestCase {
    struct TestError: Error {}
    
    @MainActor
    func testAwaitAll() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let jobs = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    concurrency += 1
                    maxConcurrency = max(concurrency, maxConcurrency)
                    
                    await withCheckedContinuation { continuation in
                        inProgress.value[index] = continuation
                    }
                    
                    inProgress.value.removeValue(forKey: index)
                    
                    concurrency -= 1
                    
                    return index
                }
            }
        
        var concurrencyReached = false
        
        let subscription = inProgress.sink { currentInProgress in
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                inProgress.value.removeValue(forKey: key)?.resume()
            }
        }
        
        let result = await jobs.awaitAll(maxConcurrency: 5)
        
        try assertEqual(.init(0..<50), result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAllThrowingNoThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        
        let jobs = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    concurrency += 1
                    maxConcurrency = max(concurrency, maxConcurrency)
                    
                    try await withCheckedThrowingContinuation { continuation in
                        inProgress.value[index] = continuation
                    }
                    
                    inProgress.value.removeValue(forKey: index)
                    
                    concurrency -= 1
                    
                    return index
                }
            }
        
        var concurrencyReached = false
        
        let subscription = inProgress.sink { currentInProgress in
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                inProgress.value.removeValue(forKey: key)?.resume()
            }
        }
        
        let result = try await jobs.awaitAll(maxConcurrency: 5)
        
        try assertEqual(.init(0..<50), result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAllThrowingThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        var completed = 0
        
        let jobs = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    concurrency += 1
                    maxConcurrency = max(concurrency, maxConcurrency)
                    
                    try await withCheckedThrowingContinuation { continuation in
                        inProgress.value[index] = continuation
                    }
                    
                    inProgress.value.removeValue(forKey: index)
                    
                    concurrency -= 1
                    completed += 1
                    
                    return index
                }
            }
        
        var concurrencyReached = false
        
        let subscription = inProgress.sink { currentInProgress in
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                let continuation = inProgress.value.removeValue(forKey: key)!
                
                if completed == 25 {
                    continuation.resume(throwing: TestError())
                } else {
                    continuation.resume()
                }
            }
        }
        
        do {
            _ = try await jobs.awaitAll(maxConcurrency: 5)
            throw Fail("Stream should have thrown")
        } catch {
            try assertTrue(error is TestError)
        }
        
        try assertEqual(completed, 25)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
}
