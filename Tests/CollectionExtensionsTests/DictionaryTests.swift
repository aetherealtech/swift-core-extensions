import Assertions
import XCTest

@testable import CollectionExtensions

final class DictionaryTests: XCTestCase {
    func testValueOrInsertPresent() throws {
        var testDictionary = [
            1: "A",
            2: "B",
            3: "C",
            4: "D",
            5: "E"
        ]
        
        let expectedResult = "C"
        
        let expectedMutation = testDictionary
        
        let result = try testDictionary.value(
            at: 3,
            orInsert: { throw Fail("Should not have been called") }()
        )
        
        try assertEqual(expectedResult, result)
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testValueOrInsertAbsent() throws {
        var testDictionary = [
            1: "A",
            2: "B",
            3: "C",
            4: "D",
            5: "E"
        ]
        
        let expectedResult = "F"
        
        let expectedMutation = [
            1: "A",
            2: "B",
            3: "C",
            4: "D",
            5: "E",
            6: "F"
        ]
        
        let result = testDictionary.value(
            at: 6,
            orInsert: "F"
        )
        
        try assertEqual(expectedResult, result)
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testInserting() throws {
        let testDictionary = [
            1: "A",
            2: "B",
            3: "C",
            4: "D",
            5: "E"
        ]
        
        let expectedResult = [
            1: "A",
            2: "B",
            3: "C",
            4: "D",
            5: "E",
            6: "F"
        ]
        
        let result = testDictionary.inserting(
            key: 6,
            value: "F"
        )
        
        try assertEqual(expectedResult, result)
    }
    
    func testMapKeysUniquingWith() throws {
        let testDictionary = [
            1: "A",
            2: "B",
            3: "C",
            4: "D",
            5: "E"
        ]
        
        let expectedResult = [
            0: "A",
            1: "C",
            2: "E",
        ]
        
        let result = testDictionary.mapKeys(
            { $0 / 2},
            uniquingKeysWith: { max($0, $1) }
        )
        
        try assertEqual(expectedResult, result)
    }
    
    func testMapKeys() throws {
        let testDictionary = [
            1: "A",
            2: "B",
            3: "C",
            4: "D",
            5: "E"
        ]
        
        let expectedResult = [
            "1": "A",
            "2": "B",
            "3": "C",
            "4": "D",
            "5": "E"
        ]
        
        let result = testDictionary
            .mapKeys(\.description)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByKeysUsingCompare() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0): "A",
            TestStruct.stub(intMember: 1): "B",
            TestStruct.stub(intMember: 2): "C",
            TestStruct.stub(intMember: 3): "D",
            TestStruct.stub(intMember: 4): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let result = testDictionary
            .sortedByKeys(using: { $0.intMember.compare(to: $1.intMember) })
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysUsingSimpleCompare() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0): "A",
            TestStruct.stub(intMember: 1): "B",
            TestStruct.stub(intMember: 2): "C",
            TestStruct.stub(intMember: 3): "D",
            TestStruct.stub(intMember: 4): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let result = testDictionary
            .sortedByKeys(using: { $0.intMember < $1.intMember })
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysByTransformUsingCompare() throws {
        let testDictionary = [
            TestStruct.stub(innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(innerMember: .stub(intMember: 3)): "D",
            TestStruct.stub(innerMember: .stub(intMember: 4)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let result = testDictionary
            .sortedByKeys(
                by: { $0.innerMember },
                using: { $0.intMember.compare(to: $1.intMember) }
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysByTransformUsingSimpleCompare() throws {
        let testDictionary = [
            TestStruct.stub(innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(innerMember: .stub(intMember: 3)): "D",
            TestStruct.stub(innerMember: .stub(intMember: 4)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let result = testDictionary
            .sortedByKeys(
                by: { $0.innerMember },
                using: { $0.intMember < $1.intMember }
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysUsingComparesVariadic() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 1)): "D",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 2)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let compare1: (TestStruct, TestStruct) -> ComparisonResult = { $0.intMember.compare(to: $1.intMember) }
        let compare2: (TestStruct, TestStruct) -> ComparisonResult = { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        
        let result = testDictionary
            .sortedByKeys(
                using: compare1, compare2
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysUsingThrowingComparesVariadic() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 1)): "D",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 2)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let compare1: (TestStruct, TestStruct) throws -> ComparisonResult = { $0.intMember.compare(to: $1.intMember) }
        let compare2: (TestStruct, TestStruct) throws -> ComparisonResult = { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        
        let result = try testDictionary
            .sortedByKeys(
                using: compare1, compare2
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysUsingComparesCollection() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 1)): "D",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 2)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let compares: [(TestStruct, TestStruct) -> ComparisonResult] = [
            { $0.intMember.compare(to: $1.intMember) },
            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        ]
        
        let result = testDictionary
            .sortedByKeys(
                using: compares
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysUsingThrowingComparesCollection() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 1)): "D",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 2)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let compares: [(TestStruct, TestStruct) throws -> ComparisonResult] = [
            { $0.intMember.compare(to: $1.intMember) },
            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        ]
        
        let result = try testDictionary
            .sortedByKeys(
                using: compares
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysByTransformsVariadic() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 1)): "D",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 2)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let transform1: (TestStruct) -> Int = { $0.intMember }
        let transform2: (TestStruct) -> Int = { $0.innerMember.intMember }
        
        let result = testDictionary
            .sortedByKeys(
                by: transform1, transform2
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysByThrowingTransformsVariadic() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 1)): "D",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 2)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let transform1: (TestStruct) throws -> Int = { $0.intMember }
        let transform2: (TestStruct) throws -> Int = { $0.innerMember.intMember }
        
        let result = try testDictionary
            .trySortedByKeys(
                by: transform1, transform2
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysByTransformsCollection() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 1)): "D",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 2)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let transforms: [(TestStruct) -> Int] = [
            { $0.intMember },
            { $0.innerMember.intMember }
        ]
        
        let result = testDictionary
            .sortedByKeys(
                by: transforms
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
    
    func testSortedByKeysByThrowingTransformsCollection() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 0)): "A",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 1)): "B",
            TestStruct.stub(intMember: 0, innerMember: .stub(intMember: 2)): "C",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 1)): "D",
            TestStruct.stub(intMember: 1, innerMember: .stub(intMember: 2)): "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted { $0.innerMember.intMember < $1.innerMember.intMember }
            .sorted { $0.intMember < $1.intMember }
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
        
        let transforms: [(TestStruct) throws -> Int] = [
            { $0.intMember },
            { $0.innerMember.intMember }
        ]
        
        let result = try testDictionary
            .sortedByKeys(
                by: transforms
            )
        
        try assertTrue(expectedResult.elementsEqual(result, by: { $0.key == $1.key && $0.value == $1.value }))
    }
}
