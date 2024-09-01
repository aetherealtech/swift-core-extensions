import Assertions
import XCTest

@testable import AsyncExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TaskTests: XCTestCase {
    struct TestError: Error {}
    
    func testSleepTimeInterval() async throws {
        let expectedTimeInterval = 0.1
        
        let start = Date()
        try await Task.sleep(timeInterval: expectedTimeInterval)
        let timeInterval = Date().timeIntervalSince(start)
        
        try assertEqual(expectedTimeInterval, timeInterval, accuracy: 0.01)
    }
    
    func testSleepUntilDate() async throws {
        let expectedDate = Date(timeIntervalSinceNow: 0.1)
        
        try await Task.sleep(until: expectedDate)
        let date = Date()
        
        try assertEqual(date.timeIntervalSince(expectedDate), 0, accuracy: 0.01)
    }
    
    func testWithTimeoutDurationNotTimedOut() async throws {
        let result = try await withTimeout(after: Duration.seconds(2)) {
            try await Task.sleep(for: Duration.milliseconds(100))
            return 5
        }
        
        try assertEqual(result, 5)
    }
    
    func testWithTimeoutDurationTimedOut() async throws {
        do {
            let _ = try await withTimeout(after: Duration.milliseconds(50)) {
                try await Task.sleep(for: Duration.milliseconds(100))
                return 5
            }
            
            throw Fail("Should have timed out")
        } catch {
            try assertTrue(error is TimedOut)
        }
    }
    
    func testWithTimeoutInstantNotTimedOut() async throws {
        let result = try await withTimeout(at: ContinuousClock().now.advanced(by: .seconds(2))) {
            try await Task.sleep(for: Duration.milliseconds(100))
            return 5
        }
        
        try assertEqual(result, 5)
    }
    
    func testWithTimeoutInstantTimedOut() async throws {
        do {
            let _ = try await withTimeout(at: ContinuousClock().now.advanced(by: .milliseconds(50))) {
                try await Task.sleep(for: Duration.milliseconds(100))
                return 5
            }
            
            throw Fail("Should have timed out")
        } catch {
            try assertTrue(error is TimedOut)
        }
    }
    
    func testWithTimeoutTimeIntervalNotTimedOut() async throws {
        let result = try await withTimeout(timeInterval: 2.0) {
            try await Task.sleep(timeInterval: 0.1)
            return 5
        }
        
        try assertEqual(result, 5)
    }
    
    func testWithTimeoutTimeIntervalTimedOut() async throws {
        do {
            let _ = try await withTimeout(timeInterval: 0.05) {
                try await Task.sleep(timeInterval: 0.1)
                return 5
            }
            
            throw Fail("Should have timed out")
        } catch {
            try assertTrue(error is TimedOut)
        }
    }
    
    func testWithTimeoutDateNotTimedOut() async throws {
        let result = try await withTimeout(at: Date().addingTimeInterval(2.0)) {
            try await Task.sleep(timeInterval: 0.1)
            return 5
        }
        
        try assertEqual(result, 5)
    }
    
    func testWithTimeoutDateTimedOut() async throws {
        do {
            let _ = try await withTimeout(at: Date().addingTimeInterval(0.05)) {
                try await Task.sleep(timeInterval: 0.1)
                return 5
            }
            
            throw Fail("Should have timed out")
        } catch {
            try assertTrue(error is TimedOut)
        }
    }
    
    final class TaskWrapper {
        var task: Task<Void, Never>
        
        init(task: Task<Void, Never>) {
            self.task = task
        }
    }
    
    // What we want to test here is that if an outer task calls `await innerTask.waitUntilDone()`, and the outer task starts before the inner task, that the outer task does not proceed past the `waitUntilDone` until after the inner task is finished.  To record that the inner task is done we use a "defer" to set a boolean flag.  We also need to control when the inner task completes.  We do that by having the inner task wait on a continuation.  The tricky part is we need this continuation to be returned back to the test function.  But the continuation isn't available until the inner task is running, which happens asynchronously.  So the test function needs to await another continuation that is resumed with the continuation for the inner task after the inner task starts.  We also need to return the inner task itself so that the test can create the outer task to call `await innerTask.waitUntilDone()`.  Since the continuation the test function is awaiting, and that returns the inner task, is continued inside the task, we need the task's block to capture the task itself.  We do this by first creating an optional `Task` and then assigning it, allowing the block to capture the `var` by reference.  The task is sure to be set by the time it is read to pass to the continuation because the only way it wouldn't be is if the spawned `Task` ran synchronously (this is all done on the `MainActor` to be thread safe).  We then need to do essentially the same thing to create the outer task that awaits the inner task.  At the end of all of this, we have two tasks and two continuations, where each continuation is what the test can use to allow a task to complete.  The test can then resume the outer continuation first, and then the inner continuation.  This allows us to test that even though the outer task proceeds before the inner task, the inner task still completes before the outer task proceeds past `waitUntilDone()`.  The assertions are done in the outer task after `waitUntilDone`().  We want to make sure the test doesn't complete before these assertions run, so the test needs to await the outer task (this is exactly what `waitUntilDone()` is for, but that's what we're testing so we use the provided `Task.value` instead).
    
    @MainActor
    func testWaitUntilDone() async throws {
        var completed = false
        
        let (innerTask, innerTaskContinuation) = await withCheckedContinuation { outerContinuation in
            var task: Task<Void, Never>?
            
            task = Task { @MainActor in
                defer { completed = true }
                                
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    outerContinuation.resume(returning: (task!, continuation))
                }
            }
        }
        
        let (outerTask, outerTaskContinuation) = await withCheckedContinuation { outerContinuation in
            var testTask: Task<Void, any Error>?
            
            testTask = Task { @MainActor in
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    outerContinuation.resume(returning: (testTask!, continuation))
                }
                
                await innerTask.waitUntilDone()
                try assertTrue(completed)
            }
        }
        
        outerTaskContinuation.resume()
        innerTaskContinuation.resume()
        
        _ = try await outerTask.value
    }
    
    @MainActor
    func testWaitUntilDoneThrowingNoThrows() async throws {
        var completed = false
        
        let (innerTask, innerTaskContinuation) = await withCheckedContinuation { outerContinuation in
            var task: Task<Void, any Error>?
            
            task = Task { @MainActor in
                defer { completed = true }
                                
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                    outerContinuation.resume(returning: (task!, continuation))
                }
            }
        }
        
        let (outerTask, outerTaskContinuation) = await withCheckedContinuation { outerContinuation in
            var testTask: Task<Void, any Error>?
            
            testTask = Task { @MainActor in
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    outerContinuation.resume(returning: (testTask!, continuation))
                }
                
                try await innerTask.waitUntilDone()
                try assertTrue(completed)
            }
        }
        
        outerTaskContinuation.resume()
        innerTaskContinuation.resume()
        
        _ = try await outerTask.value
    }
    
    @MainActor
    func testWaitUntilDoneThrowingThrows() async throws {
        let (task, continuation) = await withCheckedContinuation { outerContinuation in
            var task: Task<Void, any Error>?
            
            task = Task { @MainActor in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                    outerContinuation.resume(returning: (task!, continuation))
                }
            }
        }
        
        let (testTask, waitingContinuation) = await withCheckedContinuation { outerContinuation in
            var testTask: Task<Void, any Error>?
            
            testTask = Task { @MainActor in
                await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                    outerContinuation.resume(returning: (testTask!, continuation))
                }
                
                do {
                    try await task.waitUntilDone()
                    throw Fail("Task should have failed")
                } catch {
                    try assertTrue(error is TestError)
                }
            }
        }
        
        waitingContinuation.resume()
        continuation.resume(throwing: TestError())
        
        _ = try await testTask.value
    }
}
