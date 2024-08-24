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
        
        let activeContinuations = CurrentValueSubject<[(Int, CheckedContinuation<Void, any Error>)], Never>([])
        var cancelledTasks: Set<Int> = []
        
        let tasks = (0..<50)
            .map { index in
                { @Sendable @MainActor in
                    runningTasks.add()
                    defer { runningTasks.remove() }
                    
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
    
    func testFlattenStreamOld() async throws {
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
    
    @MainActor
    func testFlattenStream() async throws {
        let runningTasks = RunningTasks()
        
        enum TaskID {
            case outer(Int)
            case inner(Int, Int)
        }
        
        let continuations = PassthroughSubject<(TaskID, CheckedContinuation<Void, Never>), Never>()

        let tasks = (0..<10)
            .map { outerIndex in
                { @Sendable @MainActor in
                    runningTasks.add()
                    defer { runningTasks.remove() }
                    
                    await withCheckedContinuation { continuation in
                        continuations.send((.outer(outerIndex), continuation))
                    }

                    return (0..<5)
                        .map { innerIndex in
                            { @Sendable @MainActor in
                                runningTasks.add()
                                defer { runningTasks.remove() }
                                
                                await withCheckedContinuation { continuation in
                                    continuations.send((.inner(outerIndex, innerIndex), continuation))
                                }
                                
                                return (outerIndex, innerIndex)
                            }
                        }
            }
        }
        
        var startedOuterTasks: [Int] = []
        let activeOuterContinuations = CurrentValueSubject<[(Int, CheckedContinuation<Void, Never>)], Never>([])
        
        var startedInnerTasks: [(Int, [Int])] = []
        let activeInnerContinuations: [Int: CurrentValueSubject<[(Int, CheckedContinuation<Void, Never>)], Never>] = .init(uniqueKeysWithValues: (0..<10).map { ($0, .init([])) })

        let subscription = continuations.sink {
            switch $0.0 {
                case let .outer(outerIndex):
                    startedOuterTasks.append(outerIndex)
                    activeOuterContinuations.value.append((outerIndex, $0.1))
                    
                case let .inner(outerIndex, innerIndex):
                    if let startedIndex = startedInnerTasks.firstIndex(where: { $0.0 == outerIndex }) {
                        startedInnerTasks[startedIndex].1.append(innerIndex)
                    } else {
                        startedInnerTasks.append((outerIndex, [innerIndex]))
                    }
                    activeInnerContinuations[outerIndex]!.value.append((innerIndex, $0.1))
            }
        }
        
        let stream = tasks
            .flattenStream(maxConcurrency: 5)
        
        var expectedValues: [(Int, Int)] = []
      
        var receivedValues: [(Int, Int)] = []
        
        var remainingOuter = 10
        var remainingInner: [Int: Int] = [:]
        
        let fireNextOuter = { @MainActor in
            for await activeCont in activeOuterContinuations.values where !activeCont.isEmpty {
                let next = activeOuterContinuations.value.remove(at: activeOuterContinuations.value.indices.randomElement()!)
                remainingOuter -= 1
                remainingInner[next.0] = 5
                next.1.resume()
                return
            }
        }
        
        let fireNextInner: (Int) async -> Void = { @MainActor outerIndex in
            let activeContinuations = activeInnerContinuations[outerIndex]!
            
            for await activeCont in activeContinuations.values where !activeCont.isEmpty {
                let next = activeContinuations.value.remove(at: activeContinuations.value.indices.randomElement()!)
                remainingInner[outerIndex]! -= 1
                if remainingInner[outerIndex]! == 0 {
                    remainingInner[outerIndex] = nil
                }
                expectedValues.append((outerIndex, next.0))
                next.1.resume()
                return
            }
        }
        
        await fireNextOuter()
        await fireNextOuter()
        await fireNextOuter()
        
        await fireNextInner(remainingInner.keys.randomElement()!)
        
        for await index in stream {
            receivedValues.append(index)
            
            if receivedValues.count < 50 {
                while remainingOuter > 0, !activeOuterContinuations.value.isEmpty, Bool.random() {
                    await fireNextOuter()
                }
                
                if let outerIndex = remainingInner
                    .keys
                    .randomElement() {
                    await fireNextInner(outerIndex)
                }
            }
        }
        
        try assertEqual(Set(startedOuterTasks[0..<5]), Set(0..<5))
        try assertEqual(Array(startedOuterTasks[5...]), Array(5..<10))
        try assertEqual(Set(startedInnerTasks.map(\.0)), Set(0..<10))
        
        for (_, startedInnerTasksForOuterTask) in startedInnerTasks {
            try assertEqual(startedInnerTasksForOuterTask, Array(0..<5))
        }
        
        try assertTrue(expectedValues.elementsEqual(receivedValues, by: { $0.0 == $1.0 && $0.1 == $1.1 }))
        try assertEqual(runningTasks.maxRunningTasks, 5)
        
        withExtendedLifetime(subscription) { }
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
