import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class LazySequenceStringTests: XCTestCase {
    func testMapSendable() throws {
        let testSequence = DestructiveSequence([
            1,
            2,
            4,
            5,
            6,
            9,
        ])
        
        let expectedResult = [
            "1",
            "2",
            "4",
            "5",
            "6",
            "9"
        ]
        
        let result = testSequence
            .lazy
            .mapSendable { $0.description }
        
        try assertEqual(expectedResult, Array(result))
    }
}
