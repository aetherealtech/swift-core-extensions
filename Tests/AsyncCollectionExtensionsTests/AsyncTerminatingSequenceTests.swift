import Assertions
import XCTest

@testable import AsyncCollectionExtensions

final class AsyncTerminatingSequenceTests: XCTestCase {
    func testTerminate() async throws {
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
            .terminate { $0 > 4 }
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
}
