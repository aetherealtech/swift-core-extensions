import Assertions
import XCTest

@testable import CollectionExtensions

final class SetTests: XCTestCase {
    func testRemoveAllOfSequence() throws {
        var testSet: Set<Int> = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult: Set<Int> = [
            1,
            2,
            8,
            5
        ]
        
        testSet.removeAll(of: DestructiveSequence(array: [3, 9]))
        
        try assertEqual(expectedResult, testSet)
    }
    
    func testRemovingAllOfSequence() throws {
        let testSet: Set<Int> = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult: Set<Int> = [
            1,
            2,
            8,
            5
        ]
        
        let result = testSet
            .removingAll(of: DestructiveSequence(array: [3, 9]))
        
        try assertEqual(expectedResult, result)
    }
}
