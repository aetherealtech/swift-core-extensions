import Assertions
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
        
        try assertEqual(actualArray, expectedArray)
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
        
        try assertEqual(actualArray, expectedArray)
    }
    
    func testCartesianProduct() throws {
        enum SomeEnum {
            case thisCase
            case thatCase
        }
        
        let first = [0, 1, 2, 3]
        let second = ["A", "B", "C"]
        let third = [SomeEnum.thisCase, SomeEnum.thatCase]
        let fourth = [1.1, 1.2, 1.3]

        let result1 = Collections.cartesianProduct(first, second, third)
        let result2 = Collections.cartesianProduct(first, second, third, fourth)
        
        var index = 0
        
        for x in 0..<first.count {
            for y in 0..<second.count {
                for z in 0..<third.count {
                    let result = result1[index]
                    try assertEqual(result.0, first[x])
                    try assertEqual(result.1, second[y])
                    try assertEqual(result.2, third[z])
                    index += 1
                }
            }
        }
        
        index = 0
        
        for x in 0..<first.count {
            for y in 0..<second.count {
                for z in 0..<third.count {
                    for w in 0..<fourth.count {
                        let result = result2[index]
                        try assertEqual(result.0, first[x])
                        try assertEqual(result.1, second[y])
                        try assertEqual(result.2, third[z])
                        try assertEqual(result.3, fourth[w])
                        index += 1
                    }
                }
            }
        }
    }
}
