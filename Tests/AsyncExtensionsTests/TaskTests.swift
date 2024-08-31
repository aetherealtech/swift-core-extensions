import Assertions
import XCTest

@testable import AsyncExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TaskTests: XCTestCase {

    static let testError = NSError(
        domain: "Test Error",
        code: 0,
        userInfo: nil
    )

    let alwaysSuccessMapFunction: @Sendable (Int) -> String = { value in "\(value)" }
    let successMapFunction: @Sendable (Int) throws -> String = { value in "\(value)" }
    let failureMapFunction: @Sendable (Int) throws -> String = { _ in throw TaskTests.testError }

    let alwaysSuccessFlatMapFunction: @Sendable (Int) -> Task<String, Never> = { value in .init { "\(value)" } }
    let successFlatMapFunction: @Sendable (Int) -> Task<String, Error> = { value in .init { "\(value)" } }
    let failureFlatMapFunction: @Sendable (Int) -> Task<String, Error> = { _ in .init { throw TaskTests.testError } }

    let testValue = 5
    var testMappedValue: String { alwaysSuccessMapFunction(testValue) }

    var alwaysSuccessTask: () -> Task<Int, Never> { { [testValue] in Task {

        testValue
    } } }

    var successTask: () -> Task<Int, Error> { { [testValue] in Task {

        testValue
    } } }

    var failureTask: () -> Task<Int, Error> { { Task {
        
        throw TaskTests.testError
    } } }

    private func captureError<Result>(_ task: Task<Result, Error>) async -> NSError? {

        do {

            _ = try await task.value
            return nil
        }
        catch(let error) {

            return error as NSError
        }
    }
    
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

    func testMap() async {

        let task = alwaysSuccessTask()
        let mappedTask = task.map(alwaysSuccessMapFunction)

        let result = await mappedTask.value
        XCTAssertEqual(testMappedValue, result)
    }

    func testMapWithSourceErrorSuccess() async throws {

        let task = successTask()
        let mappedTask = task.map(alwaysSuccessMapFunction)

        let result = try await mappedTask.value
        XCTAssertEqual(testMappedValue, result)
    }

    func testMapWithSourceErrorFailure() async throws {

        let task = failureTask()
        let mappedTask = task.map(alwaysSuccessMapFunction)

        try await assertThrowsError(expectedError: Self.testError) { try await mappedTask.value }
    }

    func testMapWithMapErrorSuccess() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.map(successMapFunction)

        let result = try await mappedTask.value
        try assertEqual(testMappedValue, result)
    }

    func testMapWithMapErrorMapFailure() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.map(failureMapFunction)

        try await assertThrowsError(expectedError: Self.testError) { try await mappedTask.value }
    }

    func testMapWithSourceAndMapErrorSuccess() async throws {

        let task = successTask()
        let mappedTask = task.map(successMapFunction)

        let result = try await mappedTask.value
        try assertEqual(testMappedValue, result)
    }

    func testMapWithSourceAndMapErrorSourceFailure() async throws {

        let task = failureTask()
        let mappedTask = task.map(successMapFunction)

        try await assertThrowsError(expectedError: Self.testError) { try await mappedTask.value }
    }

    func testMapWithSourceAndMapErrorMapFailure() async throws {

        let task = successTask()
        let mappedTask = task.map(failureMapFunction)

        try await assertThrowsError(expectedError: Self.testError) { try await mappedTask.value }
    }

    func testFlatMap() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.flatMap(alwaysSuccessFlatMapFunction)

        let result = await mappedTask.value
        try assertEqual(testMappedValue, result)
    }

    func testFlatMapWithSourceErrorSuccess() async throws {

        let task = successTask()
        let mappedTask = task.flatMap(alwaysSuccessFlatMapFunction)

        let result = try await mappedTask.value
        try assertEqual(testMappedValue, result)
    }

    func testFlatMapWithSourceErrorFailure() async throws {

        let task = failureTask()
        let mappedTask = task.flatMap(alwaysSuccessFlatMapFunction)

        try await assertThrowsError(expectedError: Self.testError) { try await mappedTask.value }
    }

    func testFlatMapWithFlatMapErrorSuccess() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.flatMap(successFlatMapFunction)

        let result = try await mappedTask.value
        try assertEqual(testMappedValue, result)
    }

    func testFlatMapWithFlatMapErrorFlatMapFailure() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.flatMap(failureFlatMapFunction)

        try await assertThrowsError(expectedError: Self.testError) { try await mappedTask.value }
    }

    func testFlatMapWithSourceAndFlatMapErrorSuccess() async throws {

        let task = successTask()
        let mappedTask = task.flatMap(successFlatMapFunction)

        let result = try await mappedTask.value
        try assertEqual(testMappedValue, result)
    }

    func testFlatMapWithSourceAndFlatMapErrorSourceFailure() async throws {

        let task = failureTask()
        let mappedTask = task.flatMap(successFlatMapFunction)

        try await assertThrowsError(expectedError: Self.testError) { try await mappedTask.value }
    }

    func testFlatMapWithSourceAndFlatMapErrorFlatMapFailure() async throws {

        let task = successTask()
        let mappedTask = task.flatMap(failureFlatMapFunction)

        try await assertThrowsError(expectedError: Self.testError) { try await mappedTask.value }
    }

    func testCombine() async throws {
        
        let results = (0, "1", "2" as Character)
        
        let tasks = (
            Task<Int, Never> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); return results.0 },
            Task<String, Never> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); return results.1 },
            Task<Character, Never> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); return results.2 }
        )

        let combinedTask = Task.combine(
            tasks.0,
            tasks.1,
            tasks.2
        )
        
        let result = await combinedTask.value
        
        try assertTrue(result.0 == results.0 &&
                      result.1 == results.1 &&
                      result.2 == results.2
        )
    }
    
    func testCombineThrowingNoErrors() async throws {
        
        let results = (0, "1", "2" as Character)
        
        let tasks = (
            Task<Int, Error> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); return results.0 },
            Task<String, Error> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); return results.1 },
            Task<Character, Error> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); return results.2 }
        )

        let combinedTask = Task.combineThrowing(
            tasks.0,
            tasks.1,
            tasks.2
        )
        
        let result = try await combinedTask.value
        
        try assertTrue(result.0 == results.0 &&
                      result.1 == results.1 &&
                      result.2 == results.2
        )
    }
    
    func testCombineThrowingErrors() async throws {
        
        let results = (0, "1", "2" as Character)
        
        let tasks = (
            Task<Int, Error> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); return results.0 },
            Task<String, Error> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); throw Self.testError },
            Task<Character, Error> { try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000)); return results.2 }
        )

        let combinedTask = Task.combineThrowing(
            tasks.0,
            tasks.1,
            tasks.2
        )
        
        try await assertThrowsError(expectedError: Self.testError) { try await combinedTask.value }
    }
    
    func testCombineSequence() async throws {

        let results = (0..<5).map { index in

            "Task \(index)"
        }
 
        let tasks = results.map { result in

            Task<String, Never> {

                try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))
                return result
            }
        }

        let combinedTask = tasks.combine()

        let result = await combinedTask.value

        try assertTrue(result == results)
    }

//    func testMapAwaitAllAlwaysSuccess() async throws {
//
//        let values = (0..<10).map { _ in Int.random(in: 0..<100) }
//
//        let tasks = values.map { value in
//
//            Task<Int, Never> {
//
//                try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))
//                return value
//            }
//        }
//
//        let result = await tasks.awaitAll()
//
//        XCTAssertEqual(values, result)
//    }
//
//    func testMapAwaitAllSuccess() async throws {
//
//        let values = (0..<10).map { _ in Int.random(in: 0..<100) }
//
//        let tasks = values.map { value in
//
//            Task<Int, Error> {
//
//                try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))
//                return value
//            }
//        }
//
//        let result = try await tasks.awaitAll()
//
//        XCTAssertEqual(values, result)
//    }
//
//    func testMapAwaitAllFailure() async throws {
//
//        let values = (0..<10).map { _ in Int.random(in: 0..<100) }
//
//        let tasks = values.map { value in
//
//            Task<Int, Error> {
//
//                if value == values[5] {
//                    throw TaskTests.testError
//                }
//
//                try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))
//                return value
//            }
//        }
//
//        let result = Task { try await tasks.awaitAll() }
//        let error = await self.captureError(result)
//
//        XCTAssertEqual(TaskTests.testError, error)
//    }
}
