import Assertions
import Stubbing
import XCTest

@testable import CollectionExtensions

final class SequenceTests: XCTestCase {
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
        
//    func testTrySortByTransforms() throws {
//        let testArray = [
//            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 6)),
//            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 3)),
//            TestStruct.stub(intMember: 2, innerMember: .stub(intMember: 7)),
//            TestStruct.stub(intMember: 8, innerMember: .stub(intMember: 3)),
//            TestStruct.stub(intMember: 5, innerMember: .stub(intMember: 3)),
//            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 2)),
//            TestStruct.stub(intMember: 9, innerMember: .stub(intMember: 5)),
//            TestStruct.stub(intMember: 3, innerMember: .stub(intMember: 9)),
//        ]
//                            
//        let testSequence = DestructiveSequence(array: testArray)
//
//        let expectedResult = [
//            testArray[0],
//            testArray[2],
//            testArray[5],
//            testArray[1],
//            testArray[7],
//            testArray[4],
//            testArray[3],
//            testArray[6]
//        ]
//
//        let firstTransform: (TestStruct) throws -> Int = { $0.intMember }
//        let secondTransform: (TestStruct) throws -> Int = { $0.innerMember.intMember }
//
//        let result = try testSequence
//            .trySorted(by: firstTransform, secondTransform)
//
//        try assertEqual(expectedResult, result)
//    }
    
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
        
        let compares: DestructiveSequence<(TestStruct, TestStruct) -> ComparisonResult> = .init(array: [
            { $0.intMember.compare(to: $1.intMember) },
            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        ])
        
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
        
        let compares: DestructiveSequence<(TestStruct, TestStruct) throws -> ComparisonResult> = .init(array: [
            { $0.intMember.compare(to: $1.intMember) },
            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        ])
        
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
        
        let transforms: DestructiveSequence<(TestStruct) -> Int> = .init(array: [
            { $0.intMember },
            { $0.innerMember.intMember }
        ])
        
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
        
        let transforms: DestructiveSequence<(TestStruct) throws -> Int> = .init(array: [
            \.intMember,
            \.innerMember.intMember
        ])
        
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
        
        let keyPaths: DestructiveSequence<KeyPath<TestStruct, Int>> = .init(array: [
            \.intMember,
            \.innerMember.intMember
        ])

        let result = testSequence
            .sorted(by: keyPaths)
        
        try assertEqual(expectedResult, result)
    }
}
