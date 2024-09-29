import XCTest

@testable import AsyncExtensions

import Assertions
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TaskSequenceTests: XCTestCase {
    @MainActor
    final class RunningTasks {
        private(set) var runningTasks = 0
        private(set) var maxRunningTasks = 0
        
        func add() {
            runningTasks += 1
            maxRunningTasks = max(maxRunningTasks, runningTasks)
        }
        
        func remove() {
            runningTasks -= 1
        }
    }
    
    @MainActor
    final class ContinuationState<T> {
        let continuations: PassthroughSubject<(T, CheckedContinuation<Void, any Error>), Never>
        
        init(continuations: PassthroughSubject<(T, CheckedContinuation<Void, any Error>), Never>) {
            self.continuations = continuations
        }
        
        private(set) var continuation: CheckedContinuation<Void, any Error>?
        
        func set(continuation: CheckedContinuation<Void, any Error>, value: T) {
            if cancelled {
                continuation.resume(throwing: CancellationError())
            } else {
                self.continuation = continuation
                continuations.send((value, continuation))
            }
        }
        
        private(set) var cancelled = false
        
        func cancel() {
            if let continuation {
                continuation.resume(throwing: CancellationError())
            } else {
                cancelled = true
            }
        }
    }
    
    enum TaskID: Hashable {
        case outer(Int)
        case inner(Int, Int)
    }
    
    struct TestError: Error {}
    
    // We need to test that a stream obeys the max concurrency, consumes jobs in the array in order, and produces results in the order they come in.  For the last requirement, the test needs to control the order that async jobs complete.  We do that by having each job await on a continuation that is published back to the test.  The test controls the order in which jobs complete by deciding the order in which to resume the continuations.  The test also needs to be able to wait on continuations to come in, so they are stored in publishers (which can be awaited on with the .values extension).  The max concurrency is tested by keeping track of how many jobs are running simultaneously.  This is done by incrementing a counter when a job starts and decrementing that counter when the job ends, and each time recording the max value that this counter reaches.  To test that the jobs are consumed in the right order we append to an array of started tasks each time we receive a continuation, since receiving a continuation means a job has started.  The requirement for consuming jobs in order is not enforced exactly at the beginning, since the stream fires off the N jobs in parallel (where N is the max concurrency), which means their start order is indeterminate.  The requirement is rather that the first N jobs are the first N ones in the array (but not in order within these first N), and then the rest are in the same order as the array.  Combine subjects are not thread safe, so we need to read and publish to the subjects on one thread.  Isolating everything to @MainActor is the easiest way to do this.
    
    @MainActor
    func testStream() async throws {
        let runningTasks = RunningTasks()
        
        let continuations = PassthroughSubject<(Int, CheckedContinuation<Void, Never>), Never>()
        
        let tasks = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    runningTasks.add()
                    defer { runningTasks.remove() }
                    
                    await withCheckedContinuation { continuation in
                        continuations.send((index, continuation))
                    }
                    
                    return index
                }
            }
        
        var startedTasks: [Int] = []
        let activeContinuations = CurrentValueSubject<[(Int, CheckedContinuation<Void, Never>)], Never>([])

        let subscription = continuations.sink {
            startedTasks.append($0.0)
            activeContinuations.value.append($0)
        }
        
        let stream = tasks
            .stream(maxConcurrency: 5)
        
        var expectedValues: [Int] = []
      
        var receivedValues: [Int] = []
        
        let fireNext = { @MainActor in
            for await activeCont in activeContinuations.values where !activeCont.isEmpty {
                let next = activeContinuations.value.remove(at: activeContinuations.value.indices.randomElement()!)
                expectedValues.append(next.0)
                next.1.resume()
                return
            }
        }
        
        await fireNext()
        
        for await index in stream {
            receivedValues.append(index)
            
            if receivedValues.count < 50 {
                await fireNext()
            }
        }
        
        try assertEqual(Set(startedTasks[0..<5]), Set(0..<5))
        try assertEqual(Array(startedTasks[5...]), Array(5..<50))
        try assertEqual(expectedValues, receivedValues)
        try assertEqual(runningTasks.maxRunningTasks, 5)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testThrowingStreamNoThrows() async throws {
        let runningTasks = RunningTasks()
        
        let continuations = PassthroughSubject<(Int, CheckedContinuation<Void, any Error>), Never>()
        
        let tasks = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    runningTasks.add()
                    defer { runningTasks.remove() }
                    
                    try await withCheckedThrowingContinuation { continuation in
                        continuations.send((index, continuation))
                    }
                    
                    return index
                }
            }
        
        var startedTasks: [Int] = []
        let activeContinuations = CurrentValueSubject<[(Int, CheckedContinuation<Void, any Error>)], Never>([])

        let subscription = continuations.sink {
            startedTasks.append($0.0)
            activeContinuations.value.append($0)
        }
        
        let stream = tasks
            .stream(maxConcurrency: 5)
        
        var expectedValues: [Int] = []
      
        var receivedValues: [Int] = []
        
        let fireNext = { @MainActor in
            for await activeCont in activeContinuations.values where !activeCont.isEmpty {
                let next = activeContinuations.value.remove(at: activeContinuations.value.indices.randomElement()!)
                expectedValues.append(next.0)
                next.1.resume()
                return
            }
        }
        
        await fireNext()
        
        for try await index in stream {
            receivedValues.append(index)
            
            if receivedValues.count < 50 {
                await fireNext()
            }
        }
        
        try assertEqual(Set(startedTasks[0..<5]), Set(0..<5))
        try assertEqual(Array(startedTasks[5...]), Array(5..<50))
        try assertEqual(expectedValues, receivedValues)
        try assertEqual(runningTasks.maxRunningTasks, 5)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testThrowingStreamThrows() async throws {
        let runningTasks = RunningTasks()
        
        let continuations = PassthroughSubject<(Int, CheckedContinuation<Void, any Error>), Never>()
        var startedTasks: [Int] = []
        var cancelledTasks: Set<Int> = []
        
        let tasks = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    runningTasks.add()
                    defer { runningTasks.remove() }
                    
                    startedTasks.append(index)
                    
                    if Task.isCancelled {
                        cancelledTasks.insert(index)
                        throw CancellationError()
                    }
                    
                    let continuationState = ContinuationState(continuations: continuations)
                    
                    do {
                        try await withTaskCancellationHandler {
                            try await withCheckedThrowingContinuation { continuation in
                                continuationState.set(continuation: continuation, value: index)
                            }
                        } onCancel: {
                            Task { @MainActor in
                                continuationState.cancel()
                            }
                        }
                    } catch is CancellationError {
                        cancelledTasks.insert(index)
                        throw CancellationError()
                    } catch {
                        throw error
                    }

                    return index
                }
            }
        
        let activeContinuations = CurrentValueSubject<[(Int, CheckedContinuation<Void, any Error>)], Never>([])

        let subscription = continuations.sink {
            activeContinuations.value.append($0)
        }
        
        let stream = tasks
            .stream(maxConcurrency: 5)
        
        var expectedValues: [Int] = []
        var failedTask: Int?
      
        var receivedValues: [Int] = []
        
        let fireNext = { @MainActor in
            for await activeCont in activeContinuations.values where !activeCont.isEmpty {
                let next = activeContinuations.value.remove(at: activeContinuations.value.indices.randomElement()!)
                
                if expectedValues.count == 25 {
                    failedTask = next.0
                    next.1.resume(throwing: TestError())
                } else {
                    expectedValues.append(next.0)
                    next.1.resume()
                }
                
                return
            }
        }
        
        await fireNext()
        
        do {
            for try await index in stream {
                receivedValues.append(index)
                
                if receivedValues.count < 50 {
                    await fireNext()
                }
            }
            
            throw Fail("Stream should have thrown")
        } catch {
            try assertTrue(error is TestError)
        }
        
        try await Task.sleep(nanoseconds: 500_000)
        
        var expectedCancelledTasks = Set(startedTasks)
        for value in receivedValues { expectedCancelledTasks.remove(value) }
        expectedCancelledTasks.remove(failedTask!)
        
        try assertEqual(expectedValues, receivedValues)
        try assertEqual(expectedCancelledTasks, cancelledTasks)
        
        withExtendedLifetime(subscription) { }
    }

    @MainActor
    func testWaitUntilDone() async throws {
        var completed: Set<Int> = []
        
        struct TestSequence: AsyncSequence, Sendable {
            typealias Element = Void
            
            struct AsyncIterator: AsyncIteratorProtocol {
                mutating func next() async -> Void? {
                    guard current < 50 else {
                        return nil
                    }
                    
                    await MainActor.run { [self, current] in _ = completed.insert(current) }
                    current += 1
                    
                    return ()
                }
                
                let getCompleted: @Sendable @MainActor () -> Set<Int>
                let setCompleted: @Sendable @MainActor (Set<Int>) -> Void
                
                var current = 0
                
                @MainActor
                var completed: Set<Int> {
                    get { getCompleted() }
                    nonmutating set { setCompleted(newValue) }
                }
            }
            
            func makeAsyncIterator() -> AsyncIterator {
                .init(
                    getCompleted: getCompleted,
                    setCompleted: setCompleted
                )
            }
            
            let getCompleted: @Sendable @MainActor () -> Set<Int>
            let setCompleted: @Sendable @MainActor (Set<Int>) -> Void
        }
        
        await withoutActuallyEscaping({ @Sendable @MainActor in completed}) { getCompleted in
            await withoutActuallyEscaping({ @Sendable @MainActor newValue in completed = newValue }) { setCompleted in
                let sequence = TestSequence(
                    getCompleted: { completed },
                    setCompleted: { newValue in completed = newValue }
                )
                
                await sequence.waitUntilDone()
            }
        }

        try assertEqual(completed, .init(0..<50))
    }
    
    @MainActor
    func testAwaitAll() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
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
        
        await jobs.awaitAll(maxConcurrency: 5)
        
        try assertEqual(completed, .init(0..<50))
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAnyEmpty() async throws {
        let jobs: [@Sendable () async -> Int] = []
        
        let result = await jobs.awaitAny(maxConcurrency: 5)
        
        try assertNil(result)
    }
    
    @MainActor
    func testAwaitAny() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
                    
                    return index
                }
            }
        
        var concurrencyReached = false
        var expectedResult: Int?
        
        let subscription = inProgress.sink { currentInProgress in
            guard expectedResult == nil else {
                return
            }
            
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                expectedResult = key
                inProgress.value.removeValue(forKey: key)?.resume()
            }
        }
        
        let result = await jobs.awaitAny(maxConcurrency: 5)
        
        try assertEqual(result, expectedResult)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAnyVoid() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
                }
            }
        
        var concurrencyReached = false
        var expectedResult: Int?
        
        let subscription = inProgress.sink { currentInProgress in
            guard expectedResult == nil else {
                return
            }
            
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                expectedResult = key
                inProgress.value.removeValue(forKey: key)?.resume()
            }
        }
        
        await jobs.awaitAny(maxConcurrency: 5)
        
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAllThrowingNoThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
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
        
        try await jobs.awaitAll(maxConcurrency: 5)
        
        try assertEqual(completed, .init(0..<50))
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAllThrowingThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
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
                
                if completed.count == 25 {
                    continuation.resume(throwing: TestError())
                } else {
                    continuation.resume()
                }
            }
        }
        
        do {
            try await jobs.awaitAll(maxConcurrency: 5)
            throw Fail("Stream should have thrown")
        } catch {
            try assertTrue(error is TestError)
        }
        
        try assertEqual(completed.count, 25)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAnyThrowingEmpty() async throws {
        let jobs: [@Sendable () async throws -> Int] = []
        
        let result = try await jobs.awaitAny(maxConcurrency: 5)
        
        try assertNil(result)
    }
    
    @MainActor
    func testAwaitAnyThrowingNoThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
                    
                    return index
                }
            }
        
        var concurrencyReached = false
        var expectedResult: Int?
        
        let subscription = inProgress.sink { currentInProgress in
            guard expectedResult == nil else {
                return
            }
            
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                expectedResult = key
                inProgress.value.removeValue(forKey: key)?.resume()
            }
        }
        
        let result = try await jobs.awaitAny(maxConcurrency: 5)
        
        try assertEqual(result, expectedResult)
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAnyThrowingThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
                    
                    return index
                }
            }
        
        var concurrencyReached = false
        var thrown = false
        
        let subscription = inProgress.sink { currentInProgress in
            guard !thrown else {
                return
            }
            
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                thrown = true
                inProgress.value.removeValue(forKey: key)?.resume(throwing: TestError())
            }
        }
        
        do {
            let _ = try await jobs.awaitAny(maxConcurrency: 5)
            throw Fail("Stream should have thrown")
        } catch {
            try assertTrue(error is TestError)
        }
        
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAnyVoidThrowingNoThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
                }
            }
        
        var concurrencyReached = false
        var finished = false
        
        let subscription = inProgress.sink { currentInProgress in
            guard !finished else {
                return
            }
            
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                finished = true
                inProgress.value.removeValue(forKey: key)?.resume()
            }
        }
        
        try await jobs.awaitAny(maxConcurrency: 5)
        
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testAwaitAnyVoidThrowingThrows() async throws {
        var concurrency = 0
        var maxConcurrency = 0
        
        let inProgress = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        var completed: Set<Int> = []
        
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
                    completed.insert(index)
                }
            }
        
        var concurrencyReached = false
        var thrown = false
        
        let subscription = inProgress.sink { currentInProgress in
            guard !thrown else {
                return
            }
            
            if !concurrencyReached {
                if currentInProgress.count == 5 {
                    concurrencyReached = true
                } else {
                    return
                }
            }
            
            if let key = currentInProgress.keys.randomElement() {
                thrown = true
                inProgress.value.removeValue(forKey: key)?.resume(throwing: TestError())
            }
        }
        
        do {
            try await jobs.awaitAny(maxConcurrency: 5)
            throw Fail("Stream should have thrown")
        } catch {
            try assertTrue(error is TestError)
        }
        
        try assertEqual(5, maxConcurrency)
        
        withExtendedLifetime(subscription) { }
    }
}
