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
        
        struct Result: Equatable {
            let key: String
            let values: [TestStruct]
        }
        
        let expectedResult = [
            "#": [testArray[5], testArray[10]],
            "A": [testArray[2]],
            "B": [testArray[1], testArray[7]],
            "C": [testArray[0]],
            "D": [testArray[3]],
            "F": [testArray[14]],
            "G": [testArray[6]],
            "K": [testArray[8]],
            "L": [testArray[13], testArray[12]],
            "O": [testArray[11]]
        ].sorted { $0.key < $1.key }
            .map(Result.init)

        let result = testArray
            .alphabetized(by: \.stringMember)
            .map(Result.init)
        
        try assertEqual(expectedResult, result)
    }
}
