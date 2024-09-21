import Assertions
import XCTest

@testable import OptionalExtensions

final class OptionalExtensionsTests: XCTestCase {
    private struct Results: Equatable {
        let _0: Int
        let _1: Int
        let _2: Int
        let _3: Int
        let _4: Int
        
        init(_ values: (Int, Int, Int, Int, Int)) {
            _0 = values.0
            _1 = values.1
            _2 = values.2
            _3 = values.3
            _4 = values.4
        }
    }
    
    func testRequireNotNil() throws {
        let value: Int? = 3
        
        var messageClosureRan = false
        
        let result = try assertNoThrow {
            try value.require({ messageClosureRan = true; return "" }())
        }
        
        try assertEqual(result, 3)
        try assertFalse(messageClosureRan)
    }
    
    func testRequireNilMessage() throws {
        let value: Int? = nil
        
        let testMessage = "Test message"
        
        try assertThrowsError { try value.require(testMessage) } errorHandler: { error in
            guard let error = error as? UnwrappedNil else {
                throw Fail("Error should be UnwrappedNil")
            }
            
            try assertEqual(error.message, testMessage)
            try assertTrue(error.type == Int.self)
            
            try assertEqual(error.errorDescription, "Attempted to unwrap nil Optional<Int>: \(testMessage)")
        }
    }
    
    func testRequireNilError() throws {
        final class TestError: Error {}
        
        let value: Int? = nil
        
        let testError = TestError()
        
        try assertThrowsError { try value.require(testError) } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertIdentical(error, testError)
        }
    }
    
    func testFilterNotNilInclude() throws {
        let value: Int? = 3
                
        let result = value
            .filter { $0 == 3 }
        
        try assertEqual(result, 3)
    }
    
    func testFilterNotNilExclude() throws {
        let value: Int? = 3
                
        let result = value
            .filter { $0 == 4 }
        
        try assertNil(result)
    }
    
    func testFilterNil() throws {
        let value: Int? = nil
                
        let result = value
            .filter { $0 == 3 }
        
        try assertNil(result)
    }
    
    func testMapAsyncNotNil() async throws {
        let value: Int? = 3
                
        let result = await value
            .mapAsync(\.description)
        
        try assertEqual(result, "3")
    }
    
    func testMapAsyncNil() async throws {
        let value: Int? = nil
        
        let result = await value
            .mapAsync(\.description)
        
        try assertNil(result)
    }
    
    func testFlattenNotNilNotNil() throws {
        let value: Int?? = 3
                
        let result = value.flatten()
        
        try assertEqual(result, 3)
    }
    
    func testFlattenNotNilNil() throws {
        let value: Int?? = Int?.none
        
        let result = value.flatten()
        
        try assertNil(result)
    }
    
    func testFlattenNil() throws {
        let value: Int?? = Int??.none
        
        let result = value.flatten()
        
        try assertNil(result)
    }
    
    func testFlatMapAsyncNotNilNotNil() async throws {
        let value: Int? = 3
                
        let result = await value
            .flatMapAsync { $0.description }
        
        try assertEqual(result, "3")
    }
    
    func testFlatMapAsyncNotNilNil() async throws {
        let value: Int? = 3
                
        let result = await value
            .flatMapAsync { _ in nil as String? }
                
        try assertNil(result)
    }
    
    func testFlatMapAsyncNil() async throws {
        let value: Int? = nil
                
        let result = await value
            .flatMapAsync { $0.description }
                
        try assertNil(result)
    }
    
    func testFilterAsyncNotNilInclude() async throws {
        let value: Int? = 3
                
        let result = await value
            .filterAsync { $0 == 3 }
        
        try assertEqual(result, 3)
    }
    
    func testFilterAsyncNotNilExclude() async throws {
        let value: Int? = 3
                
        let result = await value
            .filterAsync { $0 == 4 }
        
        try assertNil(result)
    }
    
    func testFilterAsyncNil() async throws {
        let value: Int? = nil
                
        let result = await value
            .filterAsync { $0 == 3 }
        
        try assertNil(result)
    }
    
    func testAsArrayNotNil() throws {
        let value: Int? = 3
                
        let result = value
            .asArray()
        
        try assertEqual(result, [3])
    }
    
    func testAsArrayNil() throws {
        let value: Int? = nil
                
        let result = value
            .asArray()
        
        try assertEqual(result, [])
    }
    
    func testAsyncCoalesceNotNil() async throws {
        let value: Int? = 3
        
        let result = try await value ?? { () async throws -> Int in throw Fail("Should not have run") }
        
        try assertEqual(result, 3)
    }
    
    func testAsyncCoalesceNil() async throws {
        let value: Int? = nil
        
        let result = await value ?? { () async -> Int in 5 }
        
        try assertEqual(result, 5)
    }
    
    func testAsyncCoalesceOptionalNotNil() async throws {
        let value: Int? = 3
        
        let result = try await value ?? { () async throws -> Int? in throw Fail("Should not have run") }
        
        try assertEqual(result, 3)
    }
    
    func testAsyncCoalesceOptionalNil() async throws {
        let value: Int? = nil
        
        let result = await value ?? { () async -> Int? in 5 }
        
        try assertEqual(result, 5)
    }
    
    func testCombineSelfNotNil() throws {
        let value1: Int? = 3
        let value2: Int? = 2
        let value3: Int? = 5
        let value4: Int? = 8
        let value5: Int? = 1
        
        let result = value1.combine(
            value2,
            value3,
            value4,
            value5
        )
        .map(Results.init)
        
        try assertEqual(result, .init((3, 2, 5, 8, 1)))
    }
    
    func testCombineSelfNil() throws {
        let value1: Int? = 3
        let value2: Int? = 2
        let value3: Int? = 5
        let value4: Int? = nil
        let value5: Int? = 1
        
        let result = value1.combine(
            value2,
            value3,
            value4,
            value5
        )
        .map(Results.init)
        
        try assertNil(result)
    }
    
    func testCombineNotNil() throws {
        let value1: Int? = 3
        let value2: Int? = 2
        let value3: Int? = 5
        let value4: Int? = 8
        let value5: Int? = 1
        
        let result = Optionals.combine(
            value1,
            value2,
            value3,
            value4,
            value5
        )
        .map(Results.init)
        
        try assertEqual(result, .init((3, 2, 5, 8, 1)))
    }
    
    func testCombineNil() throws {
        let value1: Int? = 3
        let value2: Int? = 2
        let value3: Int? = 5
        let value4: Int? = nil
        let value5: Int? = 1
        
        let result = Optionals.combine(
            value1,
            value2,
            value3,
            value4,
            value5
        )
        .map(Results.init)
        
        try assertNil(result)
    }
    
    func testCombineCollectionNotNil() throws {
        let values: [Int?] = [
            3,
            2,
            5,
            8,
            1
        ]
        
        let result = values.combine()
        
        try assertEqual(result, [3, 2, 5, 8, 1])
    }
    
    func testCombineCollectionNil() throws {
        let values: [Int?] = [
            3,
            2,
            5,
            nil,
            1
        ]
        
        let result = values.combine()
        
        try assertNil(result)
    }
}
