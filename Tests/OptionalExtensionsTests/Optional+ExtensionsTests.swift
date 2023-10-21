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
}
