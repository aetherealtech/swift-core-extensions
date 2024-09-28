import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class LazySortedTests: XCTestCase {
    func testSortedBy() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        let result = testSequence
            .lazy
            .lazySorted { $0.intMember < $1.intMember }
        
        try assertEqual(expectedResult, Array(result))
    }

    func testSorted() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        let expectedResult = [
            1,
            2,
            3,
            5,
            8,
            9
        ]
        
        let result = testSequence
            .lazy
            .lazySorted()
        
        try assertEqual(expectedResult, Array(result))
    }
}
