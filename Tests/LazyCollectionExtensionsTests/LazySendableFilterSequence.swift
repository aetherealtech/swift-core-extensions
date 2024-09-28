import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class LazySendableFilterTests: XCTestCase {
    func testFilterSendable() throws {
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
            .lazy
            .filterSendable { !$0.isMultiple(of: 2) }
        
        try assertEqual(expectedResult, Array(result))
    }
}
