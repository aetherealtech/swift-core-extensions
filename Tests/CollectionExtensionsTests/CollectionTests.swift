import XCTest

@testable import CollectionExtensions

final class CollectionTests: XCTestCase {

    func testCompact() throws {
        
        let testArray: [Int?] = [
            1,
            2,
            nil,
            4,
            5,
            6,
            nil,
            nil,
            9,
            nil
        ]
        
        let expectedArray = [
            1,
            2,
            4,
            5,
            6,
            9
        ]
        
        let actualArray = testArray.compact()
        
        XCTAssertEqual(actualArray, expectedArray)
    }
    
    func testFlatten() throws {
        
        let testArray: [[Int]] = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
            [10, 11, 12]
        ]
        
        let expectedArray = Array(1...12)
        
        let actualArray = testArray.flatten()
        
        XCTAssertEqual(actualArray, expectedArray)
    }
}
