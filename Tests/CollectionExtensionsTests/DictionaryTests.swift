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
            .map(KeyValuePair.init)
        
        let result = testDictionary
            .sortedByKeys(using: { $0.intMember.compare(to: $1.intMember) })
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let result = testDictionary
            .sortedByKeys(using: { $0.intMember < $1.intMember })
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let result = testDictionary
            .sortedByKeys(
                by: { $0.innerMember },
                using: { $0.intMember.compare(to: $1.intMember) }
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let result = testDictionary
            .sortedByKeys(
                by: { $0.innerMember },
                using: { $0.intMember < $1.intMember }
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let compare1: (TestStruct, TestStruct) -> ComparisonResult = { $0.intMember.compare(to: $1.intMember) }
        let compare2: (TestStruct, TestStruct) -> ComparisonResult = { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        
        let result = testDictionary
            .sortedByKeys(
                using: compare1, compare2
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let compare1: (TestStruct, TestStruct) throws -> ComparisonResult = { $0.intMember.compare(to: $1.intMember) }
        let compare2: (TestStruct, TestStruct) throws -> ComparisonResult = { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        
        let result = try testDictionary
            .sortedByKeys(
                using: compare1, compare2
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let compares: [(TestStruct, TestStruct) -> ComparisonResult] = [
            { $0.intMember.compare(to: $1.intMember) },
            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        ]
        
        let result = testDictionary
            .sortedByKeys(
                using: compares
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let compares: [(TestStruct, TestStruct) throws -> ComparisonResult] = [
            { $0.intMember.compare(to: $1.intMember) },
            { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
        ]
        
        let result = try testDictionary
            .sortedByKeys(
                using: compares
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let transform1: (TestStruct) -> Int = { $0.intMember }
        let transform2: (TestStruct) -> Int = { $0.innerMember.intMember }
        
        let result = testDictionary
            .sortedByKeys(
                by: transform1, transform2
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let transform1: (TestStruct) throws -> Int = { $0.intMember }
        let transform2: (TestStruct) throws -> Int = { $0.innerMember.intMember }
        
        let result = try testDictionary
            .trySortedByKeys(
                by: transform1, transform2
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let transforms: [(TestStruct) -> Int] = [
            { $0.intMember },
            { $0.innerMember.intMember }
        ]
        
        let result = testDictionary
            .sortedByKeys(
                by: transforms
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
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
            .map(KeyValuePair.init)
        
        let transforms: [(TestStruct) throws -> Int] = [
            { $0.intMember },
            { $0.innerMember.intMember }
        ]
        
        let result = try testDictionary
            .sortedByKeys(
                by: transforms
            )
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
    }
    
    func testSortedByKeys() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let keys = testDictionary
            .keys
            .sorted()
        
        let expectedResult = keys
            .map { key in (key: key, value: testDictionary[key]!) }
            .map(KeyValuePair.init)

        let result = testDictionary
            .sortedByKeys()
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAllKeysWhere() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
 
        let expectedResult: Set<Int> = [
            0,
            1,
            3,
        ]

        let result = testDictionary
            .allKeys { key, value in
                key == 0 || key == 1 || value == "D"
            }
        
        try assertEqual(expectedResult, result)
    }
    
    func testAllKeysForValueBy() throws {
        let testDictionary = [
            0: TestStruct.stub(stringMember: "A"),
            1: TestStruct.stub(stringMember: "B"),
            2: TestStruct.stub(stringMember: "A"),
            3: TestStruct.stub(stringMember: "D"),
            4: TestStruct.stub(stringMember: "A")
        ]
 
        let expectedResult: Set<Int> = [
            0,
            2,
            4,
        ]

        let result = testDictionary
            .allKeys(for: TestStruct.stub(stringMember: "A"), by: { $0.stringMember == $1.stringMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testAllKeysForValue() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "A",
            3: "D",
            4: "A"
        ]
 
        let expectedResult: Set<Int> = [
            0,
            2,
            4,
        ]

        let result = testDictionary
            .allKeys(for: "A")
        
        try assertEqual(expectedResult, result)
    }
    
    func testMutableForEach() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
 
        let expectedResult = [
            0: "A0",
            1: "B1",
            2: "C2",
            3: "D3",
            4: "E4"
        ]

        testDictionary
            .mutableForEach { key, value in
                value.append(key.description)
            }
        
        try assertEqual(expectedResult, testDictionary)
    }
    
    func testMutableForEachValues() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
 
        let expectedResult = [
            0: "AA",
            1: "BB",
            2: "CC",
            3: "DD",
            4: "EE"
        ]

        testDictionary
            .mutableForEachValues { value in
                value.append(value)
            }
        
        try assertEqual(expectedResult, testDictionary)
    }
    
    func testMapInPlace() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
 
        let expectedResult = [
            0: "A0",
            1: "B1",
            2: "C2",
            3: "D3",
            4: "E4"
        ]

        testDictionary
            .mapInPlace { key, value in
                value.appending(key.description)
            }
        
        try assertEqual(expectedResult, testDictionary)
    }
    
    func testMapValuesInPlace() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
 
        let expectedResult = [
            0: "AA",
            1: "BB",
            2: "CC",
            3: "DD",
            4: "EE"
        ]

        testDictionary
            .mapValuesInPlace { value in
                value.appending(value)
            }
        
        try assertEqual(expectedResult, testDictionary)
    }
    
    func testMutateAtPresent() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            1: "BF",
            2: "C",
            3: "D",
            4: "E"
        ]
 
        let expectedResult = "BF"

        let result = testDictionary
            .mutate(at: 1) { value in
                value?.append("F")
                return value
            }
        
        try assertEqual(expectedResult, result)
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testMutateAtAbsent() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = testDictionary

        let expectedResult: String? = nil

        let result = testDictionary
            .mutate(at: 6) { value in
                value?.append("F")
                return value
            }
        
        try assertEqual(expectedResult, result)
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testMutateAtRemove() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            2: "C",
            3: "D",
            4: "E"
        ]
 
        let expectedResult = "B"

        let result = testDictionary
            .mutate(at: 1) { value in
                let original = value
                value = nil
                return original
            }
        
        try assertEqual(expectedResult, result)
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testMutateAtDefaultPresent() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            1: "BF",
            2: "C",
            3: "D",
            4: "E"
        ]
 
        let expectedResult = "BF"

        let result = try testDictionary
            .mutate(at: 1, defaultValue: { throw Fail("Should not have run") }()) { value in
                value.append("F")
                return value
            }
        
        try assertEqual(expectedResult, result)
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testMutateAtDefaultAbsent() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E",
            6: "FF"
        ]

        let expectedResult = "FF"

        let result = testDictionary
            .mutate(at: 6, defaultValue: "F") { value in
                value.append("F")
                return value
            }
        
        try assertEqual(expectedResult, result)
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testFilterInPlace() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        testDictionary
            .filterInPlace { $0.key.isMultiple(of: 2) }
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testFilterKeysInPlace() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        testDictionary
            .filterKeysInPlace { $0.isMultiple(of: 2) }
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testFilterKeys() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedResult = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        let result = testDictionary
            .filterKeys { $0.isMultiple(of: 2) }
        
        try assertEqual(expectedResult, result)
    }
    
    func testFilterValuesInPlace() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        testDictionary
            .filterValuesInPlace { ["A", "C", "E"].contains($0) }
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testFilterValues() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedResult = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        let result = testDictionary
            .filterValues { ["A", "C", "E"].contains($0) }
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveWhere() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            3: "D",
        ]
 
        testDictionary
            .remove { $0.key.isMultiple(of: 2) || $0.value == "B" }
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testRemovingWhere() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedResult = [
            3: "D",
        ]
 
        let result = testDictionary
            .removing { $0.key.isMultiple(of: 2) || $0.value == "B" }
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveKeysWhere() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        testDictionary
            .removeKeys { !$0.isMultiple(of: 2) }
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testRemovingKeysWhere() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedResult = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        let result = testDictionary
            .removingKeys { !$0.isMultiple(of: 2) }
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveValuesWhere() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        testDictionary
            .removeValues { !["A", "C", "E"].contains($0) }
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testRemovingValuesWhere() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedResult = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        let result = testDictionary
            .removingValues { !["A", "C", "E"].contains($0) }
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveKeysBy() throws {
        var testDictionary = [
            TestStruct.stub(intMember: 0): "A",
            TestStruct.stub(intMember: 1): "B",
            TestStruct.stub(intMember: 2): "C",
            TestStruct.stub(intMember: 3): "D",
            TestStruct.stub(intMember: 4): "E"
        ]
        
        let expectedMutation = testDictionary
            .filter { ![0, 2].contains($0.key.intMember) }
 
        testDictionary
            .remove(keys: [.stub(intMember: 0), .stub(intMember: 2)], by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testRemovingKeysBy() throws {
        let testDictionary = [
            TestStruct.stub(intMember: 0): "A",
            TestStruct.stub(intMember: 1): "B",
            TestStruct.stub(intMember: 2): "C",
            TestStruct.stub(intMember: 3): "D",
            TestStruct.stub(intMember: 4): "E"
        ]
        
        let expectedResult = testDictionary
            .filter { ![0, 2].contains($0.key.intMember) }
 
        let result = testDictionary
            .removing(keys: [.stub(intMember: 0), .stub(intMember: 2)], by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveValuesBy() throws {
        var testDictionary = [
            0: TestStruct.stub(stringMember: "A"),
            1: TestStruct.stub(stringMember: "B"),
            2: TestStruct.stub(stringMember: "C"),
            3: TestStruct.stub(stringMember: "D"),
            4: TestStruct.stub(stringMember: "E")
        ]
        
        let expectedMutation = testDictionary
            .filter { !["B", "D"].contains($0.value.stringMember) }
 
        testDictionary
            .remove(values: [.stub(stringMember: "B"), .stub(stringMember: "D")], by: { $0.stringMember == $1.stringMember })
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testRemovingValuesBy() throws {
        let testDictionary = [
            0: TestStruct.stub(stringMember: "A"),
            1: TestStruct.stub(stringMember: "B"),
            2: TestStruct.stub(stringMember: "C"),
            3: TestStruct.stub(stringMember: "D"),
            4: TestStruct.stub(stringMember: "E")
        ]
        
        let expectedResult = testDictionary
            .filter { !["B", "D"].contains($0.value.stringMember) }
 
        let result = testDictionary
            .removing(values: [.stub(stringMember: "B"), .stub(stringMember: "D")], by: { $0.stringMember == $1.stringMember })
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveKeys() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            1: "B",
            3: "D",
            4: "E"
        ]
 
        testDictionary
            .remove(keys: [0, 2])
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testRemovingKeys() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedResult = [
            1: "B",
            3: "D",
            4: "E"
        ]
 
        let result = testDictionary
            .removing(keys: [0, 2])
        
        try assertEqual(expectedResult, result)
    }
    
    func testRemoveValues() throws {
        var testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedMutation = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        testDictionary
            .remove(values: ["B", "D"])
        
        try assertEqual(expectedMutation, testDictionary)
    }
    
    func testRemovingValues() throws {
        let testDictionary = [
            0: "A",
            1: "B",
            2: "C",
            3: "D",
            4: "E"
        ]
        
        let expectedResult = [
            0: "A",
            2: "C",
            4: "E"
        ]
 
        let result = testDictionary
            .removing(values: ["B", "D"])
        
        try assertEqual(expectedResult, result)
    }
}
