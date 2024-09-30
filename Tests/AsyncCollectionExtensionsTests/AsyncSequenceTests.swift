import Assertions
import Stubbing
import XCTest

@testable import AsyncCollectionExtensions

enum SomeEnum {
    case thisCase
    case thatCase
}

final class AsyncSequenceTests: XCTestCase {
    func testStore() async throws {
        let expectedResult = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let testSequence = DestructiveSequence(expectedResult)
        
        let result = await testSequence
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testStoreInSet() async throws {
        let expectedResult = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let testSequence = DestructiveSequence(expectedResult)
        
        let result = await testSequence
            .store(in: Set.self)
        
        try assertEqual(Set(expectedResult), result)
    }
    
    func testStoreInDictionary() async throws {
        let expectedResult = [
            (1, "1"),
            (3, "3"),
            (2, "2"),
            (8, "8"),
            (5, "5")
        ]
        
        let testSequence = DestructiveSequence(expectedResult)
        
        let result = await testSequence
            .store(in: Dictionary.self)
        
        try assertEqual(Dictionary(uniqueKeysWithValues: expectedResult), result)
    }
    
    func testStoreInDictionaryUniquing() async throws {
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
        
        let testSequence = DestructiveSequence(expectedResult)
        
        let result = await testSequence
            .store(in: Dictionary.self, uniquingKeysWith: uniquer)
        
        try assertEqual(Dictionary(expectedResult, uniquingKeysWith: uniquer), result)
    }
    
//    func testGrouped() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            0: [2, 8],
//            1: [1, 3, 5]
//        ]
//        
//        
//        let result = try await testSequence
//            .grouped { $0 % 2 }
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedUsingCompare() async throws {
//        let testArray = [
//            TestStruct.stub(intMember: 1),
//            TestStruct.stub(intMember: 3),
//            TestStruct.stub(intMember: 2),
//            TestStruct.stub(intMember: 8),
//            TestStruct.stub(intMember: 5),
//            TestStruct.stub(intMember: 9),
//        ]
//        
//        let testSequence = DestructiveSequence(testArray)
//        
//        let expectedResult = [
//            testArray[0],
//            testArray[2],
//            testArray[1],
//            testArray[4],
//            testArray[3],
//            testArray[5]
//        ]
//        
//        let result = try await testSequence
//            .sorted(using: { $0.intMember.compare(to: $1.intMember) })
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedByTransformUsingSimpleCompare() async throws {
//        let testArray = [
//            TestStruct.stub(intMember: 1),
//            TestStruct.stub(intMember: 3),
//            TestStruct.stub(intMember: 2),
//            TestStruct.stub(intMember: 8),
//            TestStruct.stub(intMember: 5),
//            TestStruct.stub(intMember: 9),
//        ]
//        
//        let testSequence = DestructiveSequence(testArray)
//        
//        let expectedResult = [
//            testArray[0],
//            testArray[2],
//            testArray[1],
//            testArray[4],
//            testArray[3],
//            testArray[5]
//        ]
//        
//        let result = try await testSequence
//            .sorted(by: { $0.intMember }, using: <)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedByKeyPathUsingSimpleCompare() async throws {
//        let testArray = [
//            TestStruct.stub(intMember: 1),
//            TestStruct.stub(intMember: 3),
//            TestStruct.stub(intMember: 2),
//            TestStruct.stub(intMember: 8),
//            TestStruct.stub(intMember: 5),
//            TestStruct.stub(intMember: 9),
//        ]
//        
//        let testSequence = DestructiveSequence(testArray)
//        
//        let expectedResult = [
//            testArray[0],
//            testArray[2],
//            testArray[1],
//            testArray[4],
//            testArray[3],
//            testArray[5]
//        ]
//        
//        let result = try await testSequence
//            .sorted(by: \.intMember, using: <)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedByUsingCompare() async throws {
//        let testArray = [
//            TestStruct.stub(intMember: 1),
//            TestStruct.stub(intMember: 3),
//            TestStruct.stub(intMember: 2),
//            TestStruct.stub(intMember: 8),
//            TestStruct.stub(intMember: 5),
//            TestStruct.stub(intMember: 9),
//        ]
//        
//        let testSequence = DestructiveSequence(testArray)
//        
//        let expectedResult = [
//            testArray[0],
//            testArray[2],
//            testArray[1],
//            testArray[4],
//            testArray[3],
//            testArray[5]
//        ]
//        
//        let result = try await testSequence
//            .sorted(by: \.intMember, using: Int.compare)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedByTransforms() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let result = try await testSequence
//            .sorted(by: { $0.intMember }, { $0.innerMember.intMember })
//        
//        try assertEqual(expectedResult, result)
//    }
//        
//    func testTrySortByTransforms() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//    
//    func testSortedByKeyPaths() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let keyPath1: KeyPath<TestStruct, Int> = \.intMember
//        let keyPath2: KeyPath<TestStruct, Int> = \.innerMember.intMember
//        
//        let result = try await testSequence
//            .sorted(by: keyPath1, keyPath2)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedUsingComparesVariadic() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let compare1: (TestStruct, TestStruct) -> ComparisonResult = { $0.intMember.compare(to: $1.intMember) }
//        let compare2: (TestStruct, TestStruct) -> ComparisonResult = { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
//        
//        let result = try await testSequence
//            .sorted(using: compare1, compare2)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedUsingComparesThrowingVariadic() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let compare1: (TestStruct, TestStruct) throws -> ComparisonResult = { $0.intMember.compare(to: $1.intMember) }
//        let compare2: (TestStruct, TestStruct) throws -> ComparisonResult = { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
//        
//        let result = try testSequence
//            .sorted(using: compare1, compare2)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedUsingComparesSequence() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let compares: [(TestStruct, TestStruct) -> ComparisonResult] = [
//            { $0.intMember.compare(to: $1.intMember) },
//            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
//        ]
//        
//        let result = try await testSequence
//            .sorted(using: compares)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedUsingComparesThrowingArray() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let compares: [(TestStruct, TestStruct) throws -> ComparisonResult] = [
//            { $0.intMember.compare(to: $1.intMember) },
//            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
//        ]
//        
//        let result = try testSequence
//            .sorted(using: compares)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedByTransformSequence() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let transforms: [(TestStruct) -> Int] = [
//            { $0.intMember },
//            { $0.innerMember.intMember }
//        ]
//        
//        let result = try await testSequence
//            .sorted(by: transforms)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedByTransformsThrowingSequence() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let transforms: [(TestStruct) throws -> Int] = [
//            \.intMember,
//            \.innerMember.intMember
//        ]
//        
//        let result = try testSequence
//            .sorted(by: transforms)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testSortedByKeyPathSequence() async throws {
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
//        let testSequence = DestructiveSequence(testArray)
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
//        let keyPaths: [KeyPath<TestStruct, Int>] = [
//            \.intMember,
//            \.innerMember.intMember
//        ]
//
//        let result = try await testSequence
//            .sorted(by: keyPaths)
//        
//        try assertEqual(expectedResult, result)
//    }
//    
//    func testContainsByTrue() async throws {
//        let testSequence = DestructiveSequence([
//            TestStruct.stub(intMember: 0),
//            TestStruct.stub(intMember: 1),
//            TestStruct.stub(intMember: 2),
//        ])
//        
//        try assertTrue(testSequence.contains(TestStruct.stub(intMember: 0), by: { $0.intMember == $1.intMember }))
//    }
//    
//    func testContainsByFalse() async throws {
//        let testSequence = DestructiveSequence([
//            TestStruct.stub(intMember: 0),
//            TestStruct.stub(intMember: 1),
//            TestStruct.stub(intMember: 2),
//        ])
//        
//        try assertFalse(testSequence.contains(TestStruct.stub(intMember: 3), by: { $0.intMember == $1.intMember }))
//    }
    
    func testErase() async throws {
        let expectedResult = [
            TestStruct.stub(intMember: 0),
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 4),
            TestStruct.stub(intMember: 5),
        ]
        
        let testSequence = DestructiveSequence(expectedResult)
        
        let result: AnyAsyncSequence<TestStruct, any Error> = testSequence
            .erase()
  
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
    
    func testCompact() async throws {
        let testSequence = DestructiveSequence([
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
        ])
        
        let expectedResult = [
            1,
            2,
            4,
            5,
            6,
            9
        ]
        
        let result = testSequence
            .compact()
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testFlatten() async throws {
        let testSequence = DestructiveSequence([
            DestructiveSequence([1, 2, 3]),
            DestructiveSequence([4, 5, 6]),
            DestructiveSequence([7, 8, 9]),
            DestructiveSequence([10, 11, 12])
        ])
        
        let expectedResult = Array(1...12)
        
        let result = testSequence
            .flatten()
        
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
    
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    func testFlattenNoThrows() async throws {
        let testSequence = DestructiveSequence([
            DestructiveSequence([1, 2, 3]),
            DestructiveSequence([4, 5, 6]),
            DestructiveSequence([7, 8, 9]),
            DestructiveSequence([10, 11, 12])
        ])
        
        let expectedResult = Array(1...12)
        
        let result = testSequence
            .flatten()
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testFlattenSyncInner() async throws {
        let testSequence = DestructiveSequence([
            SyncDestructiveSequence([1, 2, 3]),
            SyncDestructiveSequence([4, 5, 6]),
            SyncDestructiveSequence([7, 8, 9]),
            SyncDestructiveSequence([10, 11, 12])
        ])
        
        let expectedResult = Array(1...12)
        
        let result = testSequence
            .flatten()
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testFlatMapSyncInner() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = testSequence
            .flatMap { Array(repeating: $0.description, count: $0) }
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testAppending() async throws {
        let testSequence = DestructiveSequence([
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
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
//    func testAppendingIfTrue() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            1,
//            3,
//            2,
//            8,
//            5,
//            9
//        ]
//        
//        let result = await testSequence
//            .appending(9, if: true)
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
//    
//    func testAppendingIfFalse() async throws {
//        let testArray = [
//            1,
//            3,
//            2,
//            8,
//            5
//        ]
//
//        let testSequence = DestructiveSequence(testArray)
//        
//        let result = await testSequence
//            .appending(9, if: false)
//        
//        try assertEqual(testArray, try await result.store(in: Array.self))
//    }
    
    func testAppendingSequence() async throws {
        let testSequence = DestructiveSequence([
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
            4,
            11,
            7
        ]
        
        let result = testSequence
            .appending(contentsOf: [9, 4, 11, 7].async)
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
//    func testAppendingSequenceIfTrue() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            1,
//            3,
//            2,
//            8,
//            5,
//            9,
//            1,
//            11,
//            7
//        ]
//        
//        let result = await testSequence
//            .appending(contentsOf: [9, 1, 11, 7], if: true)
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
//    
//    func testAppendingSequenceIfFalse() async throws {
//        let testArray = [
//            1,
//            3,
//            2,
//            8,
//            5
//        ]
//
//        let testSequence = DestructiveSequence(testArray)
//        
//        let result = await testSequence
//            .appending(contentsOf: [9, 1, 11, 7], if: false)
//        
//        try assertEqual(testArray, try await result.store(in: Array.self))
//    }
    
    func testPrepending() async throws {
        let testSequence = DestructiveSequence([
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
            5,
        ]
        
        let result = testSequence
            .prepending(9)
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
//    func testPrependingIfTrue() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            9,
//            1,
//            3,
//            2,
//            8,
//            5,
//        ]
//        
//        let result = await testSequence
//            .prepending(9, if: true)
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
//    
//    func testPrependingIfFalse() async throws {
//        let testArray = [
//            1,
//            3,
//            2,
//            8,
//            5
//        ]
//
//        let testSequence = DestructiveSequence(testArray)
//        
//        let result = await testSequence
//            .prepending(9, if: false)
//        
//        try assertEqual(testArray, try await result.store(in: Array.self))
//    }
    
    func testPrependingSequence() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
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
        
        let result = testSequence
            .prepending(contentsOf: [9, 4, 11, 7].async)
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
//    func testPrependingSequenceIfTrue() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            9,
//            1,
//            11,
//            7,
//            1,
//            3,
//            2,
//            8,
//            5,
//        ]
//        
//        let result = await testSequence
//            .prepending(contentsOf: [9, 1, 11, 7], if: true)
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
//    
//    func testPrependingSequenceIfFalse() async throws {
//        let testArray = [
//            1,
//            3,
//            2,
//            8,
//            5
//        ]
//
//        let testSequence = DestructiveSequence(testArray)
//        
//        let result = await testSequence
//            .prepending(contentsOf: [9, 1, 11, 7], if: false)
//        
//        try assertEqual(testArray, try await result.store(in: Array.self))
//    }
    
    func testInserting() async throws {
        let testSequence = DestructiveSequence([
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
            9,
            8,
            5,
        ]
        
        let result = testSequence
            .inserting(9, at: 3)
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
//    func testInsertingIfTrue() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            1,
//            3,
//            2,
//            9,
//            8,
//            5,
//        ]
//        
//        let result = await testSequence
//            .inserting(9, at: 3, if: true)
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
//    
//    func testInsertingIfFalse() async throws {
//        let testArray = [
//            1,
//            3,
//            2,
//            8,
//            5
//        ]
//
//        let testSequence = DestructiveSequence(testArray)
//        
//        let result = await testSequence
//            .inserting(9, at: 3, if: false)
//        
//        try assertEqual(testArray, try await result.store(in: Array.self))
//    }
    
    func testInsertingSequence() async throws {
        let testSequence = DestructiveSequence([
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
            9,
            4,
            11,
            7,
            8,
            5,
        ]
        
        let result = testSequence
            .inserting(contentsOf: [9, 4, 11, 7].async, at: 3)
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
//    func testInsertingSequenceIfTrue() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            1,
//            3,
//            2,
//            9,
//            1,
//            11,
//            7,
//            8,
//            5,
//        ]
//        
//        let result = await testSequence
//            .inserting(contentsOf: [9, 1, 11, 7], at: 3, if: true)
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
//    
//    func testInsertingSequenceIfFalse() async throws {
//        let testArray = [
//            1,
//            3,
//            2,
//            8,
//            5
//        ]
//
//        let testSequence = DestructiveSequence(testArray)
//        
//        let result = await testSequence
//            .inserting(contentsOf: [9, 1, 11, 7], at: 3, if: false)
//        
//        try assertEqual(testArray, try await result.store(in: Array.self))
//    }
    
//    func testFilterIndices() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            1,
//            2,
//            5
//        ]
//        
//        let result = await testSequence
//            .filterIndices { $0.isMultiple(of: 2) }
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
    
    func testRemovingAtIndex() async throws {
        let testSequence = DestructiveSequence([
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
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
//    func testRemovingWhereIndices() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            3,
//            8
//        ]
//        
//        let result = await testSequence
//            .removingWhereIndices { $0.isMultiple(of: 2) }
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
//    
//    func testRemovingAtIndices() async throws {
//        let testSequence = DestructiveSequence([
//            1,
//            3,
//            2,
//            8,
//            5
//        ])
//        
//        let expectedResult = [
//            1,
//            8,
//            5
//        ]
//        
//        let result = await testSequence
//            .removing(at: DestructiveSequence([1, 2]))
//        
//        try assertEqual(expectedResult, try await result.store(in: Array.self))
//    }
    
    func testRemovingAllWhere() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            5
        ]
        
        let result = testSequence
            .removingAll { $0.isMultiple(of: 2) }
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testRemovingAllOfBy() async throws {
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
        
        let testSequence = DestructiveSequence(testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        let result = testSequence
            .removingAll(of: TestStruct.stub(intMember: 3), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }

    func testRemovingAllOfSequenceBy() async throws {
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
        
        let testSequence = DestructiveSequence(testArray)
        
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
            .removingAll(of: SyncDestructiveSequence(values), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testRemovingDuplicatesBy() async throws {
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
        
        let testSequence = DestructiveSequence(testArray)
        
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
                
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testFirst() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = 1
        
        let result = await testSequence
            .first()
        
        try assertEqual(expectedResult, result)
    }
    
    func testFirstEmpty() async throws {
        let testSequence = DestructiveSequence([])
                
        let result = await testSequence
            .first()
        
        try assertNil(result)
    }
    
    func testLast() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = 5
        
        let result = await testSequence
            .last()
        
        try assertEqual(expectedResult, result)
    }
    
    func testCount() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = 5
        
        let result = await testSequence
            .count()
        
        try assertEqual(expectedResult, result)
    }
    
    func testContainsAtLeastTrue() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
                
        let result = await testSequence
            .contains(atLeast: 4)
        
        try assertTrue(result)
    }
    
    func testContainsAtLeastFalse() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
                
        let result = await testSequence
            .contains(atLeast: 6)
        
        try assertFalse(result)
    }
    
    func testAccumulate() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            10,
            11,
            14,
            16,
            24,
            29
        ]
                
        let result = testSequence
            .accumulate(10, { $0 + $1 })
                
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }

    func testRemovingAllOf() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ])
 
        let expectedResult = [
            1,
            2,
            8,
            5,
            9
        ]
        
        let result = testSequence
            .removingAll(of: 3)
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testRemovingAllOfSequence() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ])
 
        let expectedResult = [
            1,
            2,
            8,
            5
        ]
        
        let result = testSequence
            .removingAll(of: SyncDestructiveSequence([3, 9]))
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testRemovingDuplicates() async throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
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
            .removingDuplicates()
                
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
//    func testCartesianProduct() async throws {
//        let firstSource = [0, 1, 2, 3]
//        let secondSource = ["A", "B", "C"]
//        let thirdSource = [SomeEnum.thisCase, SomeEnum.thatCase]
//        let fourthSource = [1.1, 1.2, 1.3]
//        
//        var first: DestructiveSequence<[Int]> { .init(firstSource) }
//        var second: DestructiveSequence<[String]> { .init(secondSource) }
//        var third: DestructiveSequence<[SomeEnum]> { .init(thirdSource) }
//        var fourth: DestructiveSequence<[Double]> { .init(fourthSource) }
//   
//        let result1 = try await AsyncSequences.cartesianProduct(first, second, third).store(in: Array.self)
//        let result2 = try await AsyncSequences.cartesianProduct(first, second, third, fourth).store(in: Array.self)
//        
//        let result1Member = try await first.cartesianProduct(with: second, third).store(in: Array.self)
//        let result2Member = try await first.cartesianProduct(with: second, third, fourth).store(in: Array.self)
//
//        var index = 0
//
//        for x in 0..<firstSource.count {
//            for y in 0..<secondSource.count {
//                for z in 0..<thirdSource.count {
//                    let result = result1[index]
//                    try assertEqual(result.0, firstSource[x])
//                    try assertEqual(result.1, secondSource[y])
//                    try assertEqual(result.2, thirdSource[z])
//                    
//                    let resultMember = result1Member[index]
//                    try assertEqual(resultMember.0, firstSource[x])
//                    try assertEqual(resultMember.1, secondSource[y])
//                    try assertEqual(resultMember.2, thirdSource[z])
//                    
//                    index += 1
//                }
//            }
//        }
//        
//        index = 0
//        
//        for x in 0..<firstSource.count {
//            for y in 0..<secondSource.count {
//                for z in 0..<thirdSource.count {
//                    for w in 0..<fourthSource.count {
//                        let result = result2[index]
//                        try assertEqual(result.0, firstSource[x])
//                        try assertEqual(result.1, secondSource[y])
//                        try assertEqual(result.2, thirdSource[z])
//                        try assertEqual(result.3, fourthSource[w])
//                        
//                        let resultMember = result2Member[index]
//                        try assertEqual(resultMember.0, firstSource[x])
//                        try assertEqual(resultMember.1, secondSource[y])
//                        try assertEqual(resultMember.2, thirdSource[z])
//                        try assertEqual(resultMember.3, fourthSource[w])
//                        
//                        index += 1
//                    }
//                }
//            }
//        }
//    }
//    
//    func testCartesianProductEmpty() async throws {
//        let result = AsyncSequences.cartesianProduct()
//        
//        try await assertTrue(result.count() == 0)
//    }
//    
//    func testZip() async throws {
//        let firstSource = [0, 1, 2, 3]
//        let secondSource = ["A", "B", "C"]
//        let thirdSource = [SomeEnum.thisCase, SomeEnum.thatCase]
//        let fourthSource = [1.1, 1.2, 1.3]
//        
//        var first: DestructiveSequence<[Int]> { .init(firstSource) }
//        var second: DestructiveSequence<[String]> { .init(secondSource) }
//        var third: DestructiveSequence<[SomeEnum]> { .init(thirdSource) }
//        var fourth: DestructiveSequence<[Double]> { .init(fourthSource) }
// 
//        let result1 = try await AsyncSequences.zip(first, second, third).store(in: Array.self)
//        let result2 = try await AsyncSequences.zip(first, second, third, fourth).store(in: Array.self)
//        
//        let result1Member = try await first.zip(with: second, third).store(in: Array.self)
//        let result2Member = try await first.zip(with: second, third, fourth).store(in: Array.self)
//  
//        for index in 0..<2 {
//            let result = result1[index]
//            try assertEqual(result.0, firstSource[index])
//            try assertEqual(result.1, secondSource[index])
//            try assertEqual(result.2, thirdSource[index])
//            
//            let resultMember = result1Member[index]
//            try assertEqual(resultMember.0, firstSource[index])
//            try assertEqual(resultMember.1, secondSource[index])
//            try assertEqual(resultMember.2, thirdSource[index])
//        }
//        
//        for index in 0..<2 {
//            let result = result2[index]
//            try assertEqual(result.0, firstSource[index])
//            try assertEqual(result.1, secondSource[index])
//            try assertEqual(result.2, thirdSource[index])
//            try assertEqual(result.3, fourthSource[index])
//            
//            let resultMember = result2Member[index]
//            try assertEqual(resultMember.0, firstSource[index])
//            try assertEqual(resultMember.1, secondSource[index])
//            try assertEqual(resultMember.2, thirdSource[index])
//            try assertEqual(resultMember.3, fourthSource[index])
//        }
//    }
//    
//    func testZipEmpty() async throws {
//        let result = AsyncSequences.zip()
//        
//        try await assertTrue(result.count() == 0)
//    }
}
