import Assertions
import Stubbing
import XCTest

@testable import CollectionExtensions

final class SequenceTests: XCTestCase {
    enum SomeEnum {
        case thisCase
        case thatCase
    }
    
    func testStore() throws {
        let expectedResult = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let testSequence = DestructiveSequence(array: expectedResult)
        
        let result = testSequence
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testStoreInSet() throws {
        let expectedResult = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let testSequence = DestructiveSequence(array: expectedResult)
        
        let result = testSequence
            .store(in: Set.self)
        
        try assertEqual(Set(expectedResult), result)
    }
    
    func testStoreInDictionary() throws {
        let expectedResult = [
            (1, "1"),
            (3, "3"),
            (2, "2"),
            (8, "8"),
            (5, "5")
        ]
        
        let testSequence = DestructiveSequence(array: expectedResult)
        
        let result = testSequence
            .store(in: Dictionary.self)
        
        try assertEqual(Dictionary(uniqueKeysWithValues: expectedResult), result)
    }
    
    func testStoreInDictionaryUniquing() throws {
        let expectedResult = [
            (1, "11"),
            (3, "3"),
            (1, "12"),
            (2, "2"),
            (8, "8"),
            (1, "13"),
            (5, "5")
        ]
        
        let uniquer: (String, String) -> String = min
        
        let testSequence = DestructiveSequence(array: expectedResult)
        
        let result = testSequence
            .store(in: Dictionary.self, uniquingKeysWith: uniquer)
        
        try assertEqual(Dictionary(expectedResult, uniquingKeysWith: uniquer), result)
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
        
        let expectedResult = [
            1,
            2,
            4,
            5,
            6,
            9
        ]
        
        let result = testArray.compact()
        
        try assertEqual(expectedResult, result)
    }
    
    func testFlatten() throws {
        let testArray: [[Int]] = [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
            [10, 11, 12]
        ]
        
        let expectedResult = Array(1...12)
        
        let result = testArray.flatten()
        
        try assertEqual(expectedResult, result)
    }
    
    func testGrouped() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            0: [2, 8],
            1: [1, 3, 5]
        ]
        
        
        let result = testSequence
            .grouped { $0 % 2 }
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedUsingCompare() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        let result = testSequence
            .sorted(using: { $0.intMember.compare(to: $1.intMember) })
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByTransformUsingSimpleCompare() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        let result = testSequence
            .sorted(by: { $0.intMember }, using: <)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByKeyPathUsingSimpleCompare() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        let result = testSequence
            .sorted(by: \.intMember, using: <)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByUsingCompare() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 9),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[1],
            testArray[4],
            testArray[3],
            testArray[5]
        ]
        
        let result = testSequence
            .sorted(by: \.intMember, using: Int.compare)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByTransforms() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = testSequence
            .sorted(by: { $0.intMember }, { $0.innerMember.intMember })
        
        try assertEqual(expectedResult, result)
    }
        
    func testTrySortByTransforms() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
                            
        let testSequence = DestructiveSequence(array: testArray)

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

        let result = try testSequence
            .trySorted(by: firstTransform, secondTransform)

        try assertEqual(expectedResult, result)
    }
    
    func testSortedByKeyPaths() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = testSequence
            .sorted(by: keyPath1, keyPath2)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedUsingComparesVariadic() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = testSequence
            .sorted(using: compare1, compare2)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedUsingComparesThrowingVariadic() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = try testSequence
            .sorted(using: compare1, compare2)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedUsingComparesSequence() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = testSequence
            .sorted(using: compares)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedUsingComparesThrowingArray() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = try testSequence
            .sorted(using: compares)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByTransformSequence() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = testSequence
            .sorted(by: transforms)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByTransformsThrowingSequence() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = try testSequence
            .sorted(by: transforms)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByKeyPathSequence() throws {
        let testArray = [
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
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

        let result = testSequence
            .sorted(by: keyPaths)
        
        try assertEqual(expectedResult, result)
    }
    
    func testContainsByTrue() throws {
        let testSequence = DestructiveSequence(array: [
            TestStruct.stub(intMember: 0),
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 2),
        ])
        
        try assertTrue(testSequence.contains(TestStruct.stub(intMember: 0), by: { $0.intMember == $1.intMember }))
    }
    
    func testContainsByFalse() throws {
        let testSequence = DestructiveSequence(array: [
            TestStruct.stub(intMember: 0),
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 2),
        ])
        
        try assertFalse(testSequence.contains(TestStruct.stub(intMember: 3), by: { $0.intMember == $1.intMember }))
    }
    
    func testErase() throws {
        let expectedResult = [
            TestStruct.stub(intMember: 0),
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 4),
            TestStruct.stub(intMember: 5),
        ]
        
        let testSequence = DestructiveSequence(array: expectedResult)
        
        let result = Array(testSequence.erase())
  
        try assertEqual(expectedResult, result)
    }
    
    func testAppending() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        
        let result = testSequence
            .appending(9)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingIfTrue() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        
        let result = testSequence
            .appending(9, if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingIfFalse() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5
        ]
        
        
        let result = testSequence
            .appending(9, if: false)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingContentsOf() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9,
            2,
            7
        ]
        
        
        let result = testSequence
            .appending(contentsOf: DestructiveSequence(array: [9, 2, 7]))
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingContentsOfIfTrue() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9,
            2,
            7
        ]
        
        
        let result = testSequence
            .appending(contentsOf: DestructiveSequence(array: [9, 2, 7]), if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAppendingContentsOfIfFalse() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5
        ]
        
        
        let result = testSequence
            .appending(contentsOf: DestructiveSequence(array: [9, 2, 7]), if: false)
        
        try assertEqual(expectedResult, result)
    }
    
    func testPrepending() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            9,
            1,
            3,
            2,
            8,
            5
        ]
        
        
        let result = testSequence
            .prepending(9)
        
        try assertEqual(expectedResult, result)
    }
    
    func testPrependingIfTrue() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            9,
            1,
            3,
            2,
            8,
            5
        ]
        
        
        let result = testSequence
            .prepending(9, if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testPrependingIfFalse() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5
        ]
        
        
        let result = testSequence
            .prepending(9, if: false)
        
        try assertEqual(expectedResult, result)
    }
    
    func testInserting() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            9,
            2,
            8,
            5
        ]
        
        
        let result = testSequence
            .inserting(9, at: 2)
        
        try assertEqual(expectedResult, result)
    }
    
    func testInsertingIfTrue() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            9,
            2,
            8,
            5
        ]
        
        
        let result = testSequence
            .inserting(9, at: 2, if: true)
        
        try assertEqual(expectedResult, result)
    }
    
    func testInsertingIfFalse() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5
        ]
        
        
        let result = testSequence
            .inserting(9, at: 2, if: false)
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemovingAllWhere() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 4),
        ]
        
        let testSequence = DestructiveSequence(array: testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[1],
            testArray[4],
            testArray[5],
            testArray[6]
        ]
        
        let result = testSequence
            .removingAll { $0.intMember % 2 == 0 }
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemovingAtIndex() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            5
        ]
        
        let result = testSequence
            .removing(at: 3)
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemovingAtIndices() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            8,
        ]
        
        let result = testSequence
            .removing(at: [1, 2, 4])
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemovingFirst() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            3,
            2,
            8,
            5
        ]
        
        let result = testSequence
            .removingFirst()
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemovingFirstWhere() throws {
        let testSequence = DestructiveSequence(array: [
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            8,
            5
        ]
        
        let result = testSequence
            .removingFirst { $0 % 2 == 0 }
        
        try assertEqual(expectedResult, result)
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
        
        let testSequence = DestructiveSequence(array: testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        let result = testSequence
            .removingAll(of: TestStruct.stub(intMember: 3), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
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
        
        let testSequence = DestructiveSequence(array: testArray)
        
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

        let result = testSequence
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
        
        let testSequence = DestructiveSequence(array: testArray)
        
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
        
        let result = testSequence
            .removingAll(of: values, by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
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
        
        let testSequence = DestructiveSequence(array: testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[1],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        let result = testSequence
            .removingDuplicates(by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testCartesianProduct() throws {
        let first = [0, 1, 2, 3]
        let second = ["A", "B", "C"]
        let third = [SomeEnum.thisCase, SomeEnum.thatCase]
        let fourth = [1.1, 1.2, 1.3]

        let result1 = Sequences.cartesianProduct(first, second, third)
        let result2 = Sequences.cartesianProduct(first, second, third, fourth)
        
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
        let result: [()] = Sequences.cartesianProduct()
        
        try assertTrue(result.isEmpty)
    }
    
    func testZip() throws {
        let first = [0, 1, 2, 3]
        let second = ["A", "B", "C"]
        let third = [SomeEnum.thisCase, SomeEnum.thatCase]
        let fourth = [1.1, 1.2, 1.3]

        let result1 = Sequences.zip(first, second, third)
        let result2 = Sequences.zip(first, second, third, fourth)
        
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
        let result: [()] = Sequences.zip()
        
        try assertTrue(result.isEmpty)
    }
}
