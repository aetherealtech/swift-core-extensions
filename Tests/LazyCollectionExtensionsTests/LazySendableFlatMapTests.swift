import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class LazySendableFlatMapTests: XCTestCase {
    func testFlatMapSendable() throws {
        let testSequence = DestructiveSequence([
            1,
            2,
            4,
            5,
            6,
        ])
        
        let expectedResult = [
            "1",
            "2",
            "2",
            "4",
            "4",
            "4",
            "4",
            "5",
            "5",
            "5",
            "5",
            "5",
            "6",
            "6",
            "6",
            "6",
            "6",
            "6",
        ]
        
        let result = testSequence
            .lazy
            .flatMapSendable { DestructiveSequence(Array(repeating: $0.description, count: $0)) }
        
        try assertEqual(expectedResult, Array(result))
    }
}
