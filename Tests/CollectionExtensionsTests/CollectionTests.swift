import Assertions
import XCTest

@testable import CollectionExtensions

final class CollectionTests: XCTestCase {
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
    
    func testAtIndices() throws {
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
    
    func testIndicesOfSequenceBy() throws {
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
                
        let result = testArray
            .indices(of: DestructiveSequence(array: [values[0], values[1]]), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testIndicesOfCollectionBy() throws {
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
    
    func testRemovingAllWhere() throws {
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
            5
        ]
        
        let result = testArray
            .removingAll { $0.isMultiple(of: 2) }
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemovingAtIndex() throws {
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
            5
        ]
        
        let result = testArray
            .removing(at: 3)
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveAtIndices() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            8,
        ]
        
        testArray
            .remove(at: [1, 2, 4])
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testRemovingAtIndices() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            8,
        ]
        
        let result = testArray
            .removing(at: [1, 2, 4])
        
        try assertEqual(expectedResult, result)
    }
    
    func testSafelyRemoveFirstNonEmpty() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            3,
            2,
            8,
            5
        ]
        
        let result = testArray.safelyRemoveFirst()
        
        try assertEqual(1, result)
        try assertEqual(expectedMutation, testArray)
    }
    
    func testSafelyRemoveFirstEmpty() throws {
        var testArray: [Int] = []
        
        let result = testArray.safelyRemoveFirst()
        
        try assertNil(result)
    }
    
    func testRemovingFirst() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            3,
            2,
            8,
            5
        ]
        
        let result = testArray.removingFirst()
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveFirstWhere() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            1,
            2,
            8,
            5
        ]
        
        let result = testArray
            .removeFirst { $0 > 2 }
        
        try assertEqual(3, result)
        try assertEqual(expectedMutation, testArray)
    }
    
    func testRemoveFirstWhereNoMatch() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = testArray
        
        let result = testArray
            .removeFirst { $0 > 10 }
        
        try assertNil(result)
        try assertEqual(expectedMutation, testArray)
    }
    
    func testRemovingFirstWhere() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            1,
            2,
            8,
            5
        ]
        
        let result = testArray
            .removingFirst { $0 > 2 }
        
        try assertEqual(expectedResult, result)
    }
    
    func testFilterInPlace() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedMutation = [
            2,
            8
        ]
        
        testArray
            .filterInPlace { $0.isMultiple(of: 2) }
        
        try assertEqual(expectedMutation, testArray)
    }
    
    func testRemoveAllOfBy() throws {
        var testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let expectedMutation = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        testArray
            .removeAll(of: TestStruct.stub(intMember: 3), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedMutation, testArray)
    }
    
    func testRemovingAllOfBy() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        let result = testArray
            .removingAll(of: TestStruct.stub(intMember: 3), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveAllOfSequenceBy() throws {
        var testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let expectedMutation = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4]
        ]
        
        let values = [
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9)
        ]
        
        testArray
            .removeAll(of: values, by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedMutation, testArray)
    }
    
    func testRemovingAllOfSequenceBy() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4]
        ]
        
        let values = [
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9)
        ]

        let result = testArray
            .removingAll(of: DestructiveSequence(array: values), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemovingAllOfCollectionBy() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4]
        ]
        
        let values = [
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9)
        ]
        
        let result = testArray
            .removingAll(of: values, by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveDuplicatesBy() throws {
        var testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[1],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        testArray
            .removeDuplicates(by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testRemovingDuplicatesBy() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[1],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        let result = testArray
            .removingDuplicates(by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testIndicesOf() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult = [
            1,
            5,
            7
        ]
        
        let result = testArray
            .indices(of: 3)
        
        try assertEqual(expectedResult, result)
    }
        
    func testIndicesOfSequence() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult = [
            1,
            5,
            6,
            7
        ]
        
        let result = testArray
            .indices(of: DestructiveSequence(array: [3, 9]))
        
        try assertEqual(expectedResult, result)
    }
        
    func testIndicesOfCollection() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult = [
            1,
            5,
            6,
            7
        ]
        
        let result = testArray
            .indices(of: [3, 9])
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveAllOf() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult = [
            1,
            2,
            8,
            5,
            9
        ]
        
        testArray.removeAll(of: 3)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testRemovingAllOf() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult = [
            1,
            2,
            8,
            5,
            9
        ]
        
        let result = testArray.removingAll(of: 3)
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveAllOfSequence() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult = [
            1,
            2,
            8,
            5
        ]
        
        testArray.removeAll(of: DestructiveSequence(array: [3, 9]))
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testRemovingAllOfSequence() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult = [
            1,
            2,
            8,
            5
        ]
        
        let result = testArray
            .removingAll(of: DestructiveSequence(array: [3, 9]))
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemovingAllOfCollection() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
 
        let expectedResult = [
            1,
            2,
            8,
            5
        ]
        
        let result = testArray
            .removingAll(of: [3, 9])
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveDuplicates() throws {
        var testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ]
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        testArray
            .removeDuplicates()
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testRemovingDuplicates() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
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
            .removingDuplicates()
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortUsingCompare() throws {
        var testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        testArray
            .sort(using: { $0.intMember.compare(to: $1.intMember) })
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortByTransformUsingSimpleCompare() throws {
        var testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        testArray
            .sort(by: { $0.intMember }, using: <)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortByKeyPathUsingSimpleCompare() throws {
        var testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        testArray
            .sort(by: \.intMember, using: <)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortByUsingCompare() throws {
        var testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        testArray
            .sort(by: \.intMember, using: Int.compare)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortByTransforms() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        testArray
            .sort(by: { $0.intMember }, { $0.innerMember.intMember })
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testTrySortByTransforms() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let firstTransform: (TestStruct) throws -> Int = { $0.intMember }
        let secondTransform: (TestStruct) throws -> Int = { $0.innerMember.intMember }
        
        try testArray
            .trySort(by: firstTransform, secondTransform)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortByKeyPaths() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let keyPath1: KeyPath<TestStruct, Int> = \.intMember
        let keyPath2: KeyPath<TestStruct, Int> = \.innerMember.intMember
        
        testArray
            .sort(by: keyPath1, keyPath2)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortUsingComparesVariadic() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let compare1: (TestStruct, TestStruct) -> ComparisonResult = { $0.intMember.compare(to: $1.intMember) }
        let compare2: (TestStruct, TestStruct) -> ComparisonResult = { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        
        testArray
            .sort(using: compare1, compare2)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortUsingComparesThrowingVariadic() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let compare1: (TestStruct, TestStruct) throws -> ComparisonResult = { $0.intMember.compare(to: $1.intMember) }
        let compare2: (TestStruct, TestStruct) throws -> ComparisonResult = { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        
        try testArray
            .sort(using: compare1, compare2)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortUsingComparesSequence() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let compares: [(TestStruct, TestStruct) -> ComparisonResult] = [
            { $0.intMember.compare(to: $1.intMember) },
            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        ]
        
        testArray
            .sort(using: compares)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortUsingComparesThrowingArray() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let compares: [(TestStruct, TestStruct) throws -> ComparisonResult] = [
            { $0.intMember.compare(to: $1.intMember) },
            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        ]
        
        try testArray
            .sort(using: compares)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortByTransformSequence() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let transforms: [(TestStruct) -> Int] = [
            { $0.intMember },
            { $0.innerMember.intMember }
        ]
        
        testArray
            .sort(by: transforms)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortByTransformsThrowingSequence() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let transforms: [(TestStruct) throws -> Int] = [
            \.intMember,
            \.innerMember.intMember
        ]
        
        try testArray
            .sort(by: transforms)
        
        try assertEqual(expectedResult, testArray)
    }
    
    func testSortByKeyPathSequence() throws {
        var testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[5],
            testArray[1],
            testArray[7],
            testArray[4],
            testArray[3],
            testArray[6]
        ]
        
        let keyPaths: [KeyPath<TestStruct, Int>] = [
            \.intMember,
            \.innerMember.intMember
        ]

        testArray
            .sort(by: keyPaths)
        
        try assertEqual(expectedResult, testArray)
    }
}
