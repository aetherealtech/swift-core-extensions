import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class LazyFailingSequenceTests: XCTestCase {
    struct TestError: Error {}
    
    struct ErrorValue: Error, Equatable {
        let value: Int
    }

    
    func testTryFilterSucceeds() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            2,
            8
        ]
        
        let result = try testSequence
            .lazy
            .tryFilter { $0.isMultiple(of: 2) }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testTryFilterFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])

        let result = testSequence
            .lazy
            .tryFilter {
                if $0 == 8 {
                    throw TestError()
                }
                
                return $0.isMultiple(of: 2)
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testTryMapSucceeds() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "2",
            "8",
            "5"
        ]
        
        let result = try testSequence
            .lazy
            .tryMap { $0.description }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testTryMapFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
   
        let result = testSequence
            .lazy
            .tryMap {
                if $0 == 8 {
                    throw TestError()
                }
                
                return $0.description
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testTryCompactMapSucceeds() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "5"
        ]
        
        let result = try testSequence
            .lazy
            .tryCompactMap { $0.isMultiple(of: 2) ? nil : $0.description }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testTryCompactMapFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
   
        let result = testSequence
            .lazy
            .tryCompactMap {
                if $0 == 8 {
                    throw TestError()
                }
                
                return $0.description
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testTryFlatMapSucceeds() throws {
        let testSequence = DestructiveSequence([
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
        
        let result = try testSequence
            .lazy
            .tryFlatMap { Array(repeating: $0.description, count: $0) }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testTryFlatMapFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
   
        let result = testSequence
            .lazy
            .tryFlatMap {
                if $0 == 8 {
                    throw TestError()
                }
                
                return Array(repeating: $0.description, count: $0)
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testTryFlatMapFailableSucceeds() throws {
        let testSequence = DestructiveSequence([
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
        
        let result = try testSequence
            .lazy
            .tryFlatMap { Array(repeating: .success($0.description), count: $0) }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testTryFlatMapFailableOuterFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
   
        let result = testSequence
            .lazy
            .tryFlatMap {
                if $0 == 8 {
                    throw TestError()
                }
                
                return Array(repeating: Result<String, any Error>.success($0.description), count: $0)
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testTryFlatMapFailableInnerFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
   
        let result = testSequence
            .lazy
            .tryFlatMap { element -> [Result<String, any Error>] in
                Array(repeating: element.description, count: element)
                    .enumerated()
                    .map { index, mappedElement in
                        if element == 8, index == 3 {
                            return .failure(TestError())
                        }
                        
                        return .success(mappedElement)
                    }
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testTryForEachSucceeds() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        var results: [Int] = []
        
        try testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .tryForEach { element in
                results.append(element)
            }
        
        try assertEqual(testArray, results)
    }
    
    func testTryForEachFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        var results: [Int] = []
        
        let values = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element == 2 ? .failure(TestError()) : .success(element) }
        
        try assertThrowsError {
            try values
                .tryForEach { element in
                    results.append(element)
                }
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testFilterSuccessSucceeds() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        let expectedResult = [
            2,
            8
        ]
        
        let result = try testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .filterSuccess { $0.isMultiple(of: 2) }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testFilterSuccessOuterFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])

        let result = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element == 2 ? .failure(TestError()) : .success(element) }
            .filterSuccess { $0.isMultiple(of: 2) }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testFilterSuccessInnerFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])

        let result = testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .filterSuccess {
                if $0 == 8 {
                    throw TestError()
                }
                
                return $0.isMultiple(of: 2)
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testMapSuccessSucceeds() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "2",
            "8",
            "5"
        ]
        
        let result = try testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .mapSuccess { $0.description }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testMapSuccessOuterFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])

        let result = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element == 2 ? .failure(TestError()) : .success(element) }
            .mapSuccess { $0.description }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testMapSuccessInnerFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
  
        let result = testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .mapSuccess {
                if $0 == 8 {
                    throw TestError()
                }
                
                return $0.description
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testCompactMapSuccessSucceeds() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "5"
        ]
        
        let result = try testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .compactMapSuccess { $0.isMultiple(of: 2) ? nil : $0.description }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testCompactMapSuccessOuterFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])

        let result = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element == 2 ? .failure(TestError()) : .success(element) }
            .compactMapSuccess { $0.isMultiple(of: 2) ? nil : $0.description }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testCompactMapSuccessInnerFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])

        let result = testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .compactMapSuccess {
                if $0 == 8 {
                    throw TestError()
                }
                
                return $0.isMultiple(of: 2) ? nil : $0.description
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testFlatMapSuccessSucceeds() throws {
        let testSequence = DestructiveSequence([
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
        
        let result = try testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .flatMapSuccess { Array(repeating: $0.description, count: $0) }
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testFlatMapSuccessOuterFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])

        let result = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element == 2 ? .failure(TestError()) : .success(element) }
            .flatMapSuccess { Array(repeating: $0.description, count: $0) }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testFlatMapSuccessInnerFails() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let result = testSequence
            .lazy
            .map { Result<Int, any Error>.success($0) }
            .flatMapSuccess {
                if $0 == 8 {
                    throw TestError()
                }
                
                return Array(repeating: $0.description, count: $0)
            }
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error is TestError)
        }
    }
    
    func testCatch() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            15,
            8,
            5
        ]
        
        var receivedError: (any Error)?

        let result = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element == 2 ? .failure(TestError()) : .success(element) }
            .catch { error in
                receivedError = error
                
                return 15
            }
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
        try assertTrue(receivedError is TestError)
    }
    
    func testCatchSequence() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            15,
            16,
            17,
            18,
            8,
            5
        ]
        
        var receivedError: (any Error)?

        let result = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element == 2 ? .failure(TestError()) : .success(element) }
            .catch { error in
                receivedError = error
                
                return [15, 16, 17, 18]
            }
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
        try assertTrue(receivedError is TestError)
    }
    
    func testValues() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            8,
            5
        ]
        
        let result = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element == 2 ? .failure(TestError()) : .success(element) }
            .values()
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testErrors() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            ErrorValue(value: 2),
            ErrorValue(value: 8),
        ]
        
        let result = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element.isMultiple(of: 2) ? .failure(ErrorValue(value: element)) : .success(element) }
            .errors()
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result as! [ErrorValue])
    }
    
    func testOnError() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            ErrorValue(value: 2),
            ErrorValue(value: 8),
        ]
        
        var errors: [any Error] = []
        
        _ = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element.isMultiple(of: 2) ? .failure(ErrorValue(value: element)) : .success(element) }
            .onError { error in errors.append(error) }
            .store(in: Array.self)
        
        try assertEqual(expectedResult, errors as! [ErrorValue])
    }
    
    func testPrintErrors() throws {
        // This can't really be tested, we're calling it here so that it is added to the test coverage report.
        
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
                
        _ = testSequence
            .lazy
            .map { element -> Result<Int, any Error> in element.isMultiple(of: 2) ? .failure(ErrorValue(value: element)) : .success(element) }
            .printErrors()
            .store(in: Array.self)
    }
}
