import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class LazyIfElseSequenceTests: XCTestCase {
    func testIf() throws {
        let testIfArray = [
            1,
            2,
            4,
            5,
            6,
        ]
    
        let expectedResult = testIfArray
        
        let result = LazyIfElseSequence<[Int], [Int]>.if(
            testIfArray
        )
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testElse() throws {
        let testElseArray = [
            7,
            8,
            9,
            12,
            13,
        ]
        
        let expectedResult = testElseArray
        
        let result = LazyIfElseSequence<[Int], [Int]>.else(
            testElseArray
        )
        
        try assertEqual(expectedResult, Array(result))
    }
}
