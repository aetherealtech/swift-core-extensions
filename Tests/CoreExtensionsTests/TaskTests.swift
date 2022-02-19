import XCTest

@testable import CoreExtensions

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class TaskTests: XCTestCase {

    static let testError = NSError(
        domain: "Test Error",
        code: 0,
        userInfo: nil
    )

    let alwaysSuccessMapFunction: (Int) -> String = { value in "\(value)" }
    let successMapFunction: (Int) throws -> String = { value in "\(value)" }
    let failureMapFunction: (Int) throws -> String = { _ in throw TaskTests.testError }

    let alwaysSuccessFlatMapFunction: (Int) async -> String = { value in "\(value)" }
    let successFlatMapFunction: (Int) async throws -> String = { value in "\(value)" }
    let failureFlatMapFunction: (Int) async throws -> String = { _ in throw TaskTests.testError }

    let testValue = 5
    var testMappedValue: String { alwaysSuccessMapFunction(testValue) }

    var alwaysSuccessTask: () -> Task<Int, Never> { { Task {

        self.testValue
    } } }

    var successTask: () -> Task<Int, Error> { { Task {

        self.testValue
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

        let actualError = await captureError(mappedTask)
        XCTAssertEqual(TaskTests.testError, actualError)
    }

    func testMapWithMapErrorSuccess() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.map(successMapFunction)

        let result = try await mappedTask.value
        XCTAssertEqual(testMappedValue, result)
    }

    func testMapWithMapErrorMapFailure() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.map(failureMapFunction)

        let actualError = await captureError(mappedTask)
        XCTAssertEqual(TaskTests.testError, actualError)
    }

    func testMapWithSourceAndMapErrorSuccess() async throws {

        let task = successTask()
        let mappedTask = task.map(successMapFunction)

        let result = try await mappedTask.value
        XCTAssertEqual(testMappedValue, result)
    }

    func testMapWithSourceAndMapErrorSourceFailure() async throws {

        let task = failureTask()
        let mappedTask = task.map(successMapFunction)

        let actualError = await captureError(mappedTask)
        XCTAssertEqual(TaskTests.testError, actualError)
    }

    func testMapWithSourceAndMapErrorMapFailure() async throws {

        let task = successTask()
        let mappedTask = task.map(failureMapFunction)

        let actualError = await captureError(mappedTask)
        XCTAssertEqual(TaskTests.testError, actualError)
    }

    func testFlatMap() async {

        let task = alwaysSuccessTask()
        let mappedTask = task.flatMap(alwaysSuccessFlatMapFunction)

        let result = await mappedTask.value
        XCTAssertEqual(testMappedValue, result)
    }

    func testFlatMapWithSourceErrorSuccess() async throws {

        let task = successTask()
        let mappedTask = task.flatMap(alwaysSuccessFlatMapFunction)

        let result = try await mappedTask.value
        XCTAssertEqual(testMappedValue, result)
    }

    func testFlatMapWithSourceErrorFailure() async throws {

        let task = failureTask()
        let mappedTask = task.flatMap(alwaysSuccessFlatMapFunction)

        let actualError = await captureError(mappedTask)
        XCTAssertEqual(TaskTests.testError, actualError)
    }

    func testFlatMapWithFlatMapErrorSuccess() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.flatMap(successFlatMapFunction)

        let result = try await mappedTask.value
        XCTAssertEqual(testMappedValue, result)
    }

    func testFlatMapWithFlatMapErrorFlatMapFailure() async throws {

        let task = alwaysSuccessTask()
        let mappedTask = task.flatMap(failureFlatMapFunction)

        let actualError = await captureError(mappedTask)
        XCTAssertEqual(TaskTests.testError, actualError)
    }

    func testFlatMapWithSourceAndFlatMapErrorSuccess() async throws {

        let task = successTask()
        let mappedTask = task.flatMap(successFlatMapFunction)

        let result = try await mappedTask.value
        XCTAssertEqual(testMappedValue, result)
    }

    func testFlatMapWithSourceAndFlatMapErrorSourceFailure() async throws {

        let task = failureTask()
        let mappedTask = task.flatMap(successFlatMapFunction)

        let actualError = await captureError(mappedTask)
        XCTAssertEqual(TaskTests.testError, actualError)
    }

    func testFlatMapWithSourceAndFlatMapErrorFlatMapFailure() async throws {

        let task = successTask()
        let mappedTask = task.flatMap(failureFlatMapFunction)

        let actualError = await captureError(mappedTask)
        XCTAssertEqual(TaskTests.testError, actualError)
    }

    func testCombine() async throws {

        let results = (0..<5).map { index in

            "Task \(index)"
        }

        let tasks = results.map { result in

            Task<String, Never> {

                try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))
                return result
            }
        }

        let combinedTask = tasks[0].combine(
            tasks[1],
            tasks[2],
            tasks[3],
            tasks[4]
        )

        let result = await combinedTask.value

        XCTAssertTrue(result.0 == results[0] &&
            result.1 == results[1] &&
            result.2 == results[2] &&
            result.3 == results[3] &&
            result.4 == results[4]
        )
    }

    func testMapAwaitAllAlwaysSuccess() async throws {

        let values = (0..<10).map { _ in Int.random(in: 0..<100) }

        let tasks = values.map { value in

            Task<Int, Never> {

                try! await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))
                return value
            }
        }

        let result = await tasks.awaitAll()

        XCTAssertEqual(values, result)
    }

    func testMapAwaitAllSuccess() async throws {

        let values = (0..<10).map { _ in Int.random(in: 0..<100) }

        let tasks = values.map { value in

            Task<Int, Error> {

                try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))
                return value
            }
        }

        let result = try await tasks.awaitAll()

        XCTAssertEqual(values, result)
    }

    func testMapAwaitAllFailure() async throws {

        let values = (0..<10).map { _ in Int.random(in: 0..<100) }

        let tasks = values.map { value in

            Task<Int, Error> {

                if value == values[5] {
                    throw TaskTests.testError
                }

                try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))
                return value
            }
        }

        let result = Task { try await tasks.awaitAll() }
        let error = await self.captureError(result)

        XCTAssertEqual(TaskTests.testError, error)
    }
}
