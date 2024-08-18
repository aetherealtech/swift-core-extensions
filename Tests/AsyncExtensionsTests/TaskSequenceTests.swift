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
        
        func add(runningTask: Int) {
            runningTasks += 1
            maxRunningTasks = max(maxRunningTasks, runningTasks)
        }
        
        func remove(runningTask: Int) {
            runningTasks -= 1
        }
    }
    
    struct TestError: Error {}
    
    // We need to test that a stream obeys the max concurrency, consumes jobs in the array in order, and produces results in the order they come in.  For the last requirement, the test needs to control the order that async jobs complete.  We do that by having each job await on a continuation that is published back to the test.  The test controls the order in which jobs complete by deciding the order in which to resume the continuations.  The test also needs to be able to wait on continuations to come in, so they are stored in publishers (which can be awaited on with the .values extension).  The max concurrency is tested by keeping track of how many jobs are running simultaneously.  This is done by incrementing a counter when a job starts and decrementing that counter when the job ends, and each time recording the max value that this counter reaches.  To test that the jobs are consumed in the right order we append to an array of started tasks each time we receive a continuation, since receiving a continuation means a job has started.  The requirement for consuming jobs in order is not enforced exactly at the beginning, since the stream fires off the N jobs in parallel (where N is the max concurrency), which means their start order is indeterminate.  The requirement is rather that the first N jobs are the first N ones in the array (but not in order within these first N), and then the rest are in the same order as the array.  Combine subjects are not thread safe, so we need to read and publish to the subjects on one thread.  Isolating the closures to @MainActor is the easiest way to do this.
    func testStream() async throws {
        let runningTasks = RunningTasks()
        
        let continuations = PassthroughSubject<(Int, CheckedContinuation<Void, Never>), Never>()
        
        let tasks = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    runningTasks.add(runningTask: index)
                    defer { runningTasks.remove(runningTask: index) }
                    
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
        try assertEqual(await runningTasks.maxRunningTasks, 5)
        
        withExtendedLifetime(subscription) { }
    }
    
    func testThrowingStreamNoThrows() async throws {
        let runningTasks = RunningTasks()
        
        let continuations = PassthroughSubject<(Int, CheckedContinuation<Void, any Error>), Never>()
        
        let tasks = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    await runningTasks.add(runningTask: index)
                    defer { runningTasks.remove(runningTask: index) }
                    
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
        try assertEqual(await runningTasks.maxRunningTasks, 5)
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testThrowingStreamThrows() async throws {
        let runningTasks = RunningTasks()
        
        let continuations = PassthroughSubject<(Int, CheckedContinuation<Void, any Error>), Never>()
        
        let activeContinuations = CurrentValueSubject<[(Int, CheckedContinuation<Void, any Error>)], Never>([])
        var cancelledTasks: Set<Int> = []
        
        let tasks = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    runningTasks.add(runningTask: index)
                    defer { runningTasks.remove(runningTask: index) }
                    
                    if Task.isCancelled {
                        cancelledTasks.insert(index)
                        throw CancellationError()
                    }
                    
                    @MainActor
                    final class ContinuationState {
                        let continuations: PassthroughSubject<(Int, CheckedContinuation<Void, any Error>), Never>
                        
                        init(continuations: PassthroughSubject<(Int, CheckedContinuation<Void, any Error>), Never>) {
                            self.continuations = continuations
                        }
                        
                        private(set) var continuation: CheckedContinuation<Void, any Error>?
                        
                        func set(continuation: CheckedContinuation<Void, any Error>, index: Int) {
                            if cancelled {
                                continuation.resume(throwing: CancellationError())
                            } else {
                                self.continuation = continuation
                                continuations.send((index, continuation))
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
                    
                    let continuationState = ContinuationState(continuations: continuations)
                    
                    do {
                        try await withTaskCancellationHandler {
                            try await withCheckedThrowingContinuation { continuation in
                                continuationState.set(continuation: continuation, index: index)
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
        
        var startedTasks: [Int] = []

        let subscription = continuations.sink {
            startedTasks.append($0.0)
            activeContinuations.value.append($0)
        }
        
        let stream = tasks
            .stream(maxConcurrency: 5)
        
        var expectedValues: [Int] = []
        var expectedCancelledTasks: Set<Int> = []
      
        var receivedValues: [Int] = []
        
        let fireNext = { @MainActor in
            for await activeCont in activeContinuations.values where !activeCont.isEmpty {
                let next = activeContinuations.value.remove(at: activeContinuations.value.indices.randomElement()!)
                
                if expectedValues.count == 25 {
                    expectedCancelledTasks = .init(startedTasks)
                    for value in receivedValues { expectedCancelledTasks.remove(value) }
                    expectedCancelledTasks.remove(next.0)
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
        
        await Task.yield()
        await Task.yield()
        
        try assertEqual(expectedValues, receivedValues)
        try assertEqual(expectedCancelledTasks, cancelledTasks)
        
        withExtendedLifetime(subscription) { }
    }
    
    func testFlattenStream() async throws {
        print("Let's Go")
        
        let stream = (0..<50)
            .map { outerIndex in
                { @Sendable in
                    try! await Task.sleep(timeInterval: 0.01)

                    return (0..<10)
                        .map { innerIndex in
                            { @Sendable in
                                try! await Task.sleep(timeInterval: 0.01)
                                return "\(outerIndex)-\(innerIndex)"
                            }
                        }
                }
            }
            .flattenStream(maxConcurrency: 5)
        
        for await index in stream {
            print("RECEIVING: \(index)")
        }
        
        print("All Done")
    }
    
    func testAwaitAll() async throws {
        print("Let's Go")
        
        await (0..<50)
            .map { index in
                { @Sendable in
                    print("STARTING \(index)")
                    try! await Task.sleep(timeInterval: 0.01)
                    print("ENDING \(index)")
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
    
    func testAwaitAllThrowing() async throws {
        print("Let's Go")
        
        try await (0..<50)
            .map { index in
                { @Sendable in
                    print("STARTING \(index)")
                    try await Task.sleep(timeInterval: 0.01)
                    print("ENDING \(index)")
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
}
