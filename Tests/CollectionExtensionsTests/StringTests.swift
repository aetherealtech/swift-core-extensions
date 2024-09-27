import Assertions
import XCTest

@testable import CollectionExtensions

final class StringTests: XCTestCase {
    func testJoinedNonEmpty() throws {
        let testStrings = [
            "",
            "Yo",
            "",
            "",
            "Sup",
            "Bro",
            "",
            "Dude",
            ""
        ]
        
        let expectedResult = "Yo++Sup++Bro++Dude"
        
        let result = String(testStrings
            .joinedNonEmpty(separator: "++"))
        
        try assertEqual(expectedResult, result)
    }
    
    func testAlphabetizedByNameNoThrows() throws {
        let testArray = [
            TestStruct.stub(stringMember: "Cherries"),
            TestStruct.stub(stringMember: "Bananas"),
            TestStruct.stub(stringMember: "Apples"),
            TestStruct.stub(stringMember: "Dates"),
            TestStruct.stub(stringMember: ""),
            TestStruct.stub(stringMember: "10 Strawberries"),
            TestStruct.stub(stringMember: "Grapes"),
            TestStruct.stub(stringMember: "Blackberries"),
            TestStruct.stub(stringMember: "Kiwis"),
            TestStruct.stub(stringMember: ""),
            TestStruct.stub(stringMember: "50 Blueberries"),
            TestStruct.stub(stringMember: "Oranges"),
            TestStruct.stub(stringMember: "Limes"),
            TestStruct.stub(stringMember: "Lemons"),
            TestStruct.stub(stringMember: "Figs"),
        ]
  
        let expectedResult = [
            ("#", ["10 Strawberries", "50 Blueberries"]),
            ("A", ["Apples"]),
            ("B", ["Bananas", "Blackberries"]),
            ("C", ["Cherries"]),
            ("D", ["Dates"]),
            ("F", ["Figs"]),
            ("G", ["Grapes"]),
            ("K", ["Kiwis"]),
            ("L", ["Lemons", "Limes"]),
            ("O", ["Oranges"])
        ].map { (key, values) in (key, values.map { value in testArray.first { match in match.stringMember == value }! }) }
            .map(KeyValuePair.init)

        let result = testArray
            .alphabetized(by: \.stringMember)
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAlphabetizedByNameThrows() throws {
        let testArray = [
            TestStruct.stub(stringMember: "Cherries"),
            TestStruct.stub(stringMember: "Bananas"),
            TestStruct.stub(stringMember: "Apples"),
            TestStruct.stub(stringMember: "Dates"),
            TestStruct.stub(stringMember: ""),
            TestStruct.stub(stringMember: "10 Strawberries"),
            TestStruct.stub(stringMember: "Grapes"),
            TestStruct.stub(stringMember: "Blackberries"),
            TestStruct.stub(stringMember: "Kiwis"),
            TestStruct.stub(stringMember: ""),
            TestStruct.stub(stringMember: "50 Blueberries"),
            TestStruct.stub(stringMember: "Oranges"),
            TestStruct.stub(stringMember: "Limes"),
            TestStruct.stub(stringMember: "Lemons"),
            TestStruct.stub(stringMember: "Figs"),
        ]
        
        let expectedResult = [
            ("#", ["10 Strawberries", "50 Blueberries"]),
            ("A", ["Apples"]),
            ("B", ["Bananas", "Blackberries"]),
            ("C", ["Cherries"]),
            ("D", ["Dates"]),
            ("F", ["Figs"]),
            ("G", ["Grapes"]),
            ("K", ["Kiwis"]),
            ("L", ["Lemons", "Limes"]),
            ("O", ["Oranges"])
        ].map { (key, values) in (key, values.map { value in testArray.first { match in match.stringMember == value }! }) }
            .map(KeyValuePair.init)

        let result = try testArray
            .alphabetized { value throws -> String in value.stringMember }
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
    }
    
    func testAlphabetized() throws {
        let testArray = [
            "Cherries",
            "Bananas",
            "Apples",
            "Dates",
            "",
            "10 Strawberries",
            "Grapes",
            "Blackberries",
            "Kiwis",
            "",
            "50 Blueberries",
            "Oranges",
            "Limes",
            "Lemons",
            "Figs",
        ]
        
        let expectedResult = [
            ("#", ["10 Strawberries", "50 Blueberries"]),
            ("A", ["Apples"]),
            ("B", ["Bananas", "Blackberries"]),
            ("C", ["Cherries"]),
            ("D", ["Dates"]),
            ("F", ["Figs"]),
            ("G", ["Grapes"]),
            ("K", ["Kiwis"]),
            ("L", ["Lemons", "Limes"]),
            ("O", ["Oranges"])
        ].map(KeyValuePair.init)

        let result = testArray
            .alphabetized
            .map(KeyValuePair.init)
        
        try assertEqual(expectedResult, result)
    }
    
    func testNSRange() throws {
        let strings = [
            "",
            "1",
            "22",
            "333",
            "4444",
            "55555"
        ]
        
        let expectedResults = [
            NSMakeRange(0, 0),
            NSMakeRange(0, 1),
            NSMakeRange(0, 2),
            NSMakeRange(0, 3),
            NSMakeRange(0, 4),
            NSMakeRange(0, 5),
        ]
        
        let results = strings.map(\.nsRange)
        
        try assertEqual(expectedResults, results)
    }
    
    func testNilIfEmpty() throws {
        let strings = [
            "",
            "1",
            "22",
            "333",
            "4444",
            "55555"
        ]
        
        let expectedResults = [
            nil,
            "1",
            "22",
            "333",
            "4444",
            "55555"
        ]
        
        let results = strings.map(\.nilIfEmpty)
        
        try assertEqual(expectedResults, results)
    }
    
    func testEmbeddedAsLiteralRoundtrip() throws {
        let string = "Hello \"Person\""
        
        let result = try string.embeddedAsLiteral.extractedStringLiteral
        
        try assertEqual(string, result)
    }
    
    func testEmbeddedAsLiteral() throws {
        let string = "Hello \"Person\""
        
        let expectedResult = "\"Hello \\\"Person\\\"\""
        
        let result = string.embeddedAsLiteral
        
        try assertEqual(expectedResult, result)
    }
    
    func testExtractedLiteral() throws {
        let string = "\"Hello \\\"Person\\\"\""
        
        let expectedResult = "Hello \"Person\""
        
        let result = try string.extractedStringLiteral
        
        try assertEqual(expectedResult, result)
    }
}
