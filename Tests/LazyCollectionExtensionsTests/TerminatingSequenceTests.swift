import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class TerminatingSequenceTests: XCTestCase {
    func testTerminate() throws {
        let testSequence = DestructiveSequence([
            1,
            2,
            4,
            5,
            3,
            1,
            6,
            2,
            9,
        ])
        
        let expectedResult = [
            1,
            2,
            4
        ]
        
        let result = testSequence
            .lazy
            .terminate { $0 > 4 }
        
        try assertEqual(expectedResult, Array(result))
    }
}
