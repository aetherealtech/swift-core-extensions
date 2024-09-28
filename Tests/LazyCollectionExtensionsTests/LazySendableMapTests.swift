import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class LazySendableMapTests: XCTestCase {
    func testMapSendable() throws {
        let testSequence = DestructiveSequence([
            1,
            2,
            4,
            5,
            6,
            9,
        ])
        
        let expectedResult = [
            "1",
            "2",
            "4",
            "5",
            "6",
            "9"
        ]
        
        let result = testSequence
            .lazy
            .mapSendable { $0.description }
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRandomAccess() throws {
        let testArray = [
            1,
            2,
            4,
            5,
            6,
            9,
        ]
            
        let result = testArray
            .lazy.mapSendable { $0.description }
        
        try assertEqual(result.startIndex, testArray.startIndex)
        try assertEqual(result.endIndex, testArray.endIndex)
        
        try assertEqual(result.indices, testArray.indices)
        
        for i in testArray.indices {
            try assertEqual(testArray[i].description, result[i])
        }
        
        var index = 2
        var resultIndex = index
        
        testArray.formIndex(after: &index)
        result.formIndex(after: &resultIndex)
        
        try assertEqual(index, resultIndex)
        
        testArray.formIndex(before: &index)
        result.formIndex(before: &resultIndex)
        
        try assertEqual(index, resultIndex)
        
        try assertEqual(testArray.index(index, offsetBy: 2), result.index(resultIndex, offsetBy: 2))

        try assertEqual(testArray.index(index, offsetBy: 1, limitedBy: 5), result.index(resultIndex, offsetBy: 1, limitedBy: 5))
        
        try assertEqual(testArray.index(index, offsetBy: 5, limitedBy: 1), result.index(resultIndex, offsetBy: 5, limitedBy: 1))
    }
}
