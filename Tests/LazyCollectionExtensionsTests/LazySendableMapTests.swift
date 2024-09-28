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
        
        let index = 2
  
        try assertEqual(testArray.index(after: index), result.index(after: index))

        try assertEqual(testArray.index(before: index), result.index(before: index))
        
        try assertEqual(testArray.index(index, offsetBy: 2), result.index(index, offsetBy: 2))

        try assertEqual(testArray.index(index, offsetBy: 1, limitedBy: 5), result.index(index, offsetBy: 1, limitedBy: 5))
        
        try assertEqual(testArray.index(index, offsetBy: 5, limitedBy: 1), result.index(index, offsetBy: 5, limitedBy: 1))
    }
}
