import Assertions
import Combine
import Stubbing
import XCTest

@testable import AsyncCollectionExtensions

final class SequenceAsyncTests: XCTestCase {
    func testForEachAsync() async throws {
        let testArray = [
            1,
            2,
            3,
            4,
            5
        ]
        
        let testSequence = SyncDestructiveSequence(testArray)
        
        var results: [Int] = []
        
        await testSequence
            .forEachAsync { results.append($0) }
        
        try assertEqual(testArray, results)
    }
    
    func testMapAsync() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            2,
            3,
            4,
            5
        ])
        
        let expectedResult = [
            "1",
            "2",
            "3",
            "4",
            "5"
        ]
                
        let results = await testSequence
            .mapAsync { $0.description }
        
        try assertEqual(expectedResult, results)
    }
    
    func testMapAsyncCollection() async throws {
        let testSequence = [
            1,
            2,
            3,
            4,
            5
        ]
        
        let expectedResult = [
            "1",
            "2",
            "3",
            "4",
            "5"
        ]
                
        let results = await testSequence
            .mapAsync { $0.description }
        
        try assertEqual(expectedResult, results)
    }
    
    func testCompactMapAsync() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            2,
            nil,
            4,
            5,
            6,
            nil,
            nil,
            9,
            nil
        ])
        
        let expectedResult = [
            "1",
            "2",
            "4",
            "5",
            "6",
            "9"
        ]
        
        let result = await testSequence
            .compactMapAsync { $0?.description }
        
        try assertEqual(expectedResult, result)
    }
    
    func testCompactMapAsyncCollection() async throws {
        let testSequence = [
            1,
            2,
            nil,
            4,
            5,
            6,
            nil,
            nil,
            9,
            nil
        ]
        
        let expectedResult = [
            "1",
            "2",
            "4",
            "5",
            "6",
            "9"
        ]
        
        let result = await testSequence
            .compactMapAsync { $0?.description }
        
        try assertEqual(expectedResult, result)
    }
    
    func testFlatMapAsync() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = await testSequence
            .flatMapAsync { SyncDestructiveSequence(Array(repeating: $0.description, count: $0)) }
        
        try assertEqual(expectedResult, result)
    }
    
    func testFlattenAsync() async throws {
        let testSequence = SyncDestructiveSequence([
            DestructiveSequence([1, 2, 3]),
            DestructiveSequence([4, 5, 6]),
            DestructiveSequence([7, 8, 9]),
            DestructiveSequence([10, 11, 12])
        ])
        
        let expectedResult = Array(1...12)
        
        let result = try await testSequence
            .flattenAsync()
        
        try assertEqual(expectedResult, result)
    }
    
    func testFlatMapAsyncAsyncInner() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = try await testSequence
            .flatMapAsync { DestructiveSequence(Array(repeating: $0.description, count: $0)) }
        
        try assertEqual(expectedResult, result)
    }
    
    @MainActor
    func testParallelForEach() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
        
        var result: Set<Int> = []
        
        await values.parallelForEach(maxConcurrency: 5) { @MainActor index in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            result.insert(index)
        }
                
        try assertEqual(.init(0..<50), result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelForEachThrowing() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
        
        var result: Set<Int> = []
        
        try await values.parallelForEach(maxConcurrency: 5) { @MainActor index throws in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            result.insert(index)
        }
                
        try assertEqual(.init(0..<50), result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelMap() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
                
        let result = await values.parallelMap(maxConcurrency: 5) { @MainActor index in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            return index.description
        }
                
        try assertEqual((0..<50).map(\.description), result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelMapThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
                
        let result = try await values.parallelMap(maxConcurrency: 5) { @MainActor index throws in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            return index.description
        }
                
        try assertEqual((0..<50).map(\.description), result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelCompactMap() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
                
        let result = await values.parallelCompactMap(maxConcurrency: 5) { @MainActor index in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            return index.isMultiple(of: 2) ? index.description : nil
        }
                
        try assertEqual((0..<25).map { $0 * 2 }.map(\.description), result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelCompactMapThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
                
        let result = try await values.parallelCompactMap(maxConcurrency: 5) { @MainActor index throws in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            return index.isMultiple(of: 2) ? index.description : nil
        }
        
        try assertEqual((0..<25).map { $0 * 2 }.map(\.description), result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelFlatMap() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
                
        let result = await values.parallelFlatMap(maxConcurrency: 5) { @MainActor index in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            return Array(repeating: index.description, count: 3)
        }
                
        try assertEqual((0..<50).flatMap { Array(repeating: $0.description, count: 3) }, result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelFlatMapThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
                
        let result = try await values.parallelFlatMap(maxConcurrency: 5) { @MainActor index throws in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
            
            return Array(repeating: index.description, count: 3)
        }
        
        try assertEqual((0..<50).flatMap { Array(repeating: $0.description, count: 3) }, result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelFilter() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
                
        let result = await values.parallelFilter(maxConcurrency: 5) { @MainActor index in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            return index.isMultiple(of: 2)
        }
                
        try assertEqual((0..<25).map { $0 * 2 }, result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testParallelFilterThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        let values = SyncDestructiveSequence(Array(0..<50))
        
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
                
        let result = try await values.parallelFilter(maxConcurrency: 5) { @MainActor index throws in
            concurrency += 1
            maxConcurrency = max(concurrency, maxConcurrency)
            
            await withCheckedContinuation { continuation in
                inProgress.value[index] = continuation
            }
            
            inProgress.value.removeValue(forKey: index)
            
            concurrency -= 1
                        
            return index.isMultiple(of: 2)
        }
        
        try assertEqual((0..<25).map { $0 * 2 }, result)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
}
