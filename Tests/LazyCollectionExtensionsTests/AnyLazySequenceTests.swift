import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class AnyLazySequenceTests: XCTestCase {
    func testErase() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        var results: [Int] = []
        
        for element in testSequence.lazy.lazyErase() {
            results.append(element)
        }
        
        try assertEqual(results, testArray)
    }
}
