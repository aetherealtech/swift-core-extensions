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
    
    func testCartesianProductEmpty() throws {
        let result: [()] = Collections.cartesianProduct()
        
        try assertTrue(result.isEmpty)
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
    
    func testZipEmpty() throws {
        let result: [()] = Collections.zip()
        
        try assertTrue(result.isEmpty)
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
    
    func testMutableForEach() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            2,
            4,
            3,
            9,
            6
        ]
        
        testArray.mutableForEach { value in
            value += 1
        }
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testMutableMap() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            2,
            4,
            3,
            9,
            6
        ]
        
        let expectedResult = [
            "2",
            "4",
            "3",
            "9",
            "6"
        ]
        
        let result = testArray.mutableMap { value in
            value += 1
            return value.description
        }
        
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResult, result)
    }
    
    func testMutableCompactMap() throws {
        var testArray: [Int?] = [
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
        
        let expectedMutation: [Int?] = [
            2,
            3,
            -1,
            5,
            6,
            7,
            -1,
            -1,
            10,
            -1
        ]
        
        let expectedResult = [
            "2",
            "3",
            "5",
            "6",
            "7",
            "10"
        ]
        
        let result = testArray.mutableCompactMap { value -> String? in
            value? += 1
            
            guard let value else {
                value = -1
                return nil
            }
            
            return value.description
        }
        
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResult, result)
    }
    
    func testMutableFlatMap() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation: [Int?] = [
            2,
            4,
            3,
            9,
            6
        ]
        
        let expectedResult = [
            "2-1", "2-2",
            "4-1", "4-2", "4-3", "4-4",
            "3-1", "3-2", "3-3",
            "9-1", "9-2", "9-3", "9-4", "9-5", "9-6", "9-7", "9-8", "9-9",
            "6-1", "6-2", "6-3", "6-4", "6-5", "6-6",
        ]
        
        let result = testArray.mutableFlatMap { value in
            value += 1
            
            return (0..<value)
                .map { index in "\(value)-\(index + 1)" }
        }
        
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResult, result)
    }
    
    func testMapInPlace() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            2,
            4,
            3,
            9,
            6
        ]
    
        testArray.mapInPlace { value in
            return value + 1
        }
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testMutateAtIndex() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            1,
            3,
            3,
            8,
            5
        ]
        
        let expectedResult = "3"
        
        let result = testArray
            .mutate(at: 2) { value in
                value += 1
                return value.description
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResult, result)
    }
    
    func testMutateAtSafeIndexValid() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            1,
            3,
            3,
            8,
            5
        ]
        
        let expectedResult = "3"
        
        let result = testArray
            .mutate(safe: 2) { value in
                value += 1
                return value.description
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResult, result)
    }
    
    func testMutateAtSafeIndexInvalid() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            1,
            3,
            2,
            8,
            5
        ]
                
        let result = try testArray
            .mutate(safe: 10) { value -> String in
                throw Fail("Should not have been called")
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertNil(result)
    }
    
    func testMutateAtSafeIndexVoidValid() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            1,
            3,
            3,
            8,
            5
        ]
                
        let result = testArray
            .mutate(safe: 2) { value in
                value += 1
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertTrue(result)
    }
    
    func testMutateAtSafeIndexVoidInvalid() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            1,
            3,
            2,
            8,
            5
        ]
                
        let result = try testArray
            .mutate(safe: 10) { value in
                throw Fail("Should not have been called")
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertFalse(result)
    }
    
    func testMutateAtSafeIndexElseValid() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            1,
            3,
            3,
            8,
            5
        ]
        
        let expectedResult = "3"
        
        let result = try testArray
            .mutate(safe: 2) { value in
                value += 1
                return value.description
            } else: { () -> String in
                throw Fail("Should not have been executed")
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResult, result)
    }
    
    func testMutateAtSafeIndexElseInvalid() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = "Newp"
                
        let result = try testArray
            .mutate(safe: 10) { value -> String in
                throw Fail("Should not have been called")
            } else: { "Newp" }
    
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResult, result)
    }
    
    func testMutateAtIndices() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            2,
            3,
            3,
            8,
            6
        ]
        
        let expectedResults = [
            "2",
            "3",
            "6"
        ]
        
        let result = testArray
            .mutate(at: [0, 2, 4]) { value in
                value += 1
                return value.description
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResults, result)
    }
    
    func testMutateAtIndicesVoid() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            2,
            3,
            3,
            8,
            6
        ]

        testArray
            .mutate(at: [0, 2, 4]) { value in
                value += 1
            }
    
        try assertEqual(expectedMutation, testArray)
    }
    
    func testMutateAtSafeIndices() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            2,
            3,
            3,
            8,
            6
        ]
        
        let expectedResults = [
            "2",
            "3",
            "6"
        ]
        
        let result = testArray
            .mutate(safe: [0, 9, 2, 4, 30]) { value in
                value += 1
                return value.description
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResults, result)
    }
    
    func testMutateAtSafeIndicesVoid() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            2,
            3,
            3,
            8,
            6
        ]
        
        let expectedResult = 3
        
        let result = testArray
            .mutate(safe: [0, 9, 2, 4, 30]) { value in
                value += 1
            }
    
        try assertEqual(expectedMutation, testArray)
        try assertEqual(expectedResult, result)
    }
    
    func testAppending() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let result = testArray
            .appending(9)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingIfTrue() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let result = testArray
            .appending(9, if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let result = testArray
            .appending(9, if: false)
        
        try assertEqual(testArray, result)
    }
    
    func testAppendingSequence() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9,
            4,
            11,
            7
        ]
        
        let result = testArray
            .appending(contentsOf: [9, 4, 11, 7])
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingSequenceIfTrue() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9,
            1,
            11,
            7
        ]
        
        let result = testArray
            .appending(contentsOf: [9, 1, 11, 7], if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingSequenceIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let result = testArray
            .appending(contentsOf: [9, 1, 11, 7], if: false)
        
        try assertEqual(testArray, result)
    }
    
    func testPrepend() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            9,
            1,
            3,
            2,
            8,
            5,
        ]
        
        testArray.prepend(9)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testPrepending() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            9,
            1,
            3,
            2,
            8,
            5,
        ]
        
        let result = testArray
            .prepending(9)
        
        try assertEqual(expectedResult, result)
    }
    
    func testPrependingIfTrue() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            9,
            1,
            3,
            2,
            8,
            5,
        ]
        
        let result = testArray
            .prepending(9, if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testPrependingIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let result = testArray
            .prepending(9, if: false)
        
        try assertEqual(testArray, result)
    }
    
    func testPrependingSequence() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            9,
            4,
            11,
            7,
            1,
            3,
            2,
            8,
            5
        ]
        
        let result = testArray
            .prepending(contentsOf: [9, 4, 11, 7])
        
        try assertEqual(expectedResult, result)
    }
    
    func testPrependingSequenceIfTrue() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            9,
            1,
            11,
            7,
            1,
            3,
            2,
            8,
            5,
        ]
        
        let result = testArray
            .prepending(contentsOf: [9, 1, 11, 7], if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testPrependingSequenceIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let result = testArray
            .prepending(contentsOf: [9, 1, 11, 7], if: false)
        
        try assertEqual(testArray, result)
    }
    
    func testInserting() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            9,
            8,
            5,
        ]
        
        let result = testArray
            .inserting(9, at: 3)
        
        try assertEqual(expectedResult, result)
    }
    
    func testInsertingIfTrue() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            9,
            8,
            5,
        ]
        
        let result = testArray
            .inserting(9, at: 3, if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testInsertingIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let result = testArray
            .inserting(9, at: 3, if: false)
        
        try assertEqual(testArray, result)
    }
    
    func testInsertingSequence() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            9,
            4,
            11,
            7,
            8,
            5,
        ]
        
        let result = testArray
            .inserting(contentsOf: [9, 4, 11, 7], at: 3)
        
        try assertEqual(expectedResult, result)
    }
    
    func testInsertingSequenceIfTrue() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            9,
            1,
            11,
            7,
            8,
            5,
        ]
        
        let result = testArray
            .inserting(contentsOf: [9, 1, 11, 7], at: 3, if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testInsertingSequenceIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let result = testArray
            .inserting(contentsOf: [9, 1, 11, 7], at: 3, if: false)
        
        try assertEqual(testArray, result)
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
