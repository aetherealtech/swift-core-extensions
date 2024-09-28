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
        
        let testElseArray = [
            7,
            8,
            9,
            12,
            13,
        ]
        
        let expectedResult = testIfArray
        
        let result = LazyIfElseSequence(
            if: testIfArray,
            else: testElseArray,
            condition: true
        )
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testElse() throws {
        let testIfArray = [
            1,
            2,
            4,
            5,
            6,
        ]
        
        let testElseArray = [
            7,
            8,
            9,
            12,
            13,
        ]
        
        let expectedResult = testElseArray
        
        let result = LazyIfElseSequence(
            if: testIfArray,
            else: testElseArray,
            condition: false
        )
        
        try assertEqual(expectedResult, Array(result))
    }
}
