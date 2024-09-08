import Assertions
import Stubbing
import XCTest

@testable import CollectionExtensions

final class CollectionTests: XCTestCase {
    @Stubbable
    struct TestStruct: Equatable {
        @Stubbable
        struct InnerStruct: Equatable {
            var intMember: Int
            var floatMember: Double
        }
        
        var intMember: Int
        var floatMember: Double
        var stringMember: String
        var innerMember: InnerStruct
        
        func with(intMember: Int) -> Self {
            var result = self
            result.intMember = intMember
            return result
        }
    }
    
    func testIndexSafe() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        for index in testArray.indices {
            try assertEqual(testArray[safe: index], testArray[index])
        }
        
        try assertNil(testArray[safe: testArray.count])
        try assertNil(testArray[safe: testArray.count * 3])
    }
    
    func testIndices() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let indices = [
            0,
            2,
            3
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3]
        ]
        
        try assertEqual(expectedResult, testArray[indices])
    }
    
    func testIndicesSafe() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let indices = [
            0,
            2,
            3,
            10
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3]
        ]
        
        try assertEqual(expectedResult, testArray[safe: indices])
    }
    
    func testContainsBy() throws {
        let testArray = [
            TestStruct.stub.with(intMember: 0),
            TestStruct.stub.with(intMember: 1),
            TestStruct.stub.with(intMember: 2),
        ]
        
        try assertTrue(testArray.contains(TestStruct.stub.with(intMember: 0), by: { $0.intMember == $1.intMember }))
        try assertFalse(testArray.contains(TestStruct.stub.with(intMember: 3), by: { $0.intMember == $1.intMember }))
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
        
        let result1Member = first.cartesianProduct(with: second, third)
        let result2Member = first.cartesianProduct(with: second, third, fourth)
        
        var index = 0
        
        for x in 0..<first.count {
            for y in 0..<second.count {
                for z in 0..<third.count {
                    let result = result1[index]
                    try assertEqual(result.0, first[x])
                    try assertEqual(result.1, second[y])
                    try assertEqual(result.2, third[z])
                    
                    let resultMember = result1Member[index]
                    try assertEqual(resultMember.0, first[x])
                    try assertEqual(resultMember.1, second[y])
                    try assertEqual(resultMember.2, third[z])
                    
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
                        
                        let resultMember = result2Member[index]
                        try assertEqual(resultMember.0, first[x])
                        try assertEqual(resultMember.1, second[y])
                        try assertEqual(resultMember.2, third[z])
                        try assertEqual(resultMember.3, fourth[w])
                        
                        index += 1
                    }
                }
            }
        }
    }
    
    func testZip() throws {
        enum SomeEnum {
            case thisCase
            case thatCase
        }
        
        let first = [0, 1, 2, 3]
        let second = ["A", "B", "C"]
        let third = [SomeEnum.thisCase, SomeEnum.thatCase]
        let fourth = [1.1, 1.2, 1.3]

        let result1 = Collections.zip(first, second, third)
        let result2 = Collections.zip(first, second, third, fourth)
        
        let result1Member = first.zip(with: second, third)
        let result2Member = first.zip(with: second, third, fourth)
        
        for index in 0..<2 {
            let result = result1[index]
            try assertEqual(result.0, first[index])
            try assertEqual(result.1, second[index])
            try assertEqual(result.2, third[index])
            
            let resultMember = result1Member[index]
            try assertEqual(resultMember.0, first[index])
            try assertEqual(resultMember.1, second[index])
            try assertEqual(resultMember.2, third[index])
        }
        
        for index in 0..<2 {
            let result = result2[index]
            try assertEqual(result.0, first[index])
            try assertEqual(result.1, second[index])
            try assertEqual(result.2, third[index])
            try assertEqual(result.3, fourth[index])
            
            let resultMember = result2Member[index]
            try assertEqual(resultMember.0, first[index])
            try assertEqual(resultMember.1, second[index])
            try assertEqual(resultMember.2, third[index])
            try assertEqual(resultMember.3, fourth[index])
        }
    }
    
    func testIndicesWhere() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            12,
            15,
            16,
            4,
            11,
            3,
            9,
            8
        ]
 
        let expectedResult = [
            2,
            3,
            5,
            7,
            8,
            12
        ]
        
        try assertEqual(expectedResult, testArray.indices { $0.isMultiple(of: 2) })
    }
    
    func testIndicesOfValueBy() throws {
        let values = (0..<3)
            .map { _ in TestStruct.stub }
        
        let testArray = [
            values[0],
            values[2],
            values[1],
            values[1],
            values[0],
            values[1],
            values[2],
            values[1],
            values[0],
            values[2],
        ]
 
        let expectedResult = [
            2,
            3,
            5,
            7
        ]
                
        try assertEqual(expectedResult, testArray.indices(of: values[1], by: { $0.intMember == $1.intMember }))
    }
    
    func testIndicesOfValuesBy() throws {
        let values = (0..<3)
            .map { _ in TestStruct.stub }
        
        let testArray = [
            values[0],
            values[2],
            values[1],
            values[1],
            values[0],
            values[1],
            values[2],
            values[1],
            values[0],
            values[2],
        ]
 
        let expectedResult = [
            0,
            2,
            3,
            4,
            5,
            7,
            8
        ]
                
        try assertEqual(expectedResult, testArray.indices(of: [values[0], values[1]], by: { $0.intMember == $1.intMember }))
    }
    
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
}
