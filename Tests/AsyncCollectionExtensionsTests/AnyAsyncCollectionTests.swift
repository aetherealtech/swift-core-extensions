import Assertions
import XCTest

@testable import AsyncCollectionExtensions

final class TypedThrowDestructiveSequence<Base: Sequence, Failure: Error>: AsyncSequence, AsyncIteratorProtocol {
    func next() async throws -> Base.Element? {
        iterator.next()
    }
    
    func next(isolation actor: isolated (any Actor)?) async throws(Failure) -> Base.Element? {
        iterator.next()
    }
    
    func makeAsyncIterator() -> TypedThrowDestructiveSequence {
        self
    }
    
    init(_ base: Base) {
        iterator = base.makeIterator()
    }
    
    private var iterator: Base.Iterator
}

final class AnyAsyncSequenceTests: XCTestCase {
    struct TestError: Error {
        let tag = 0
    }
    
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    func testEraseTypedError() async throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let testSequence = TypedThrowDestructiveSequence<[Int], TestError>(testArray)
        
        var results: [Int] = []
        
        let erased: AnyAsyncSequence<Int, TestError> = testSequence.erase()
        
        do {
            for try await element in erased {
                results.append(element)
            }
        } catch {
            // Compiles only if the error is typed to `TestError`
            _ = error.tag
        }
        
        try assertEqual(results, testArray)
        
        let erasedAgain: AnyAsyncSequence<Int, TestError> = testSequence.erase()
        var iterator = erasedAgain.makeAsyncIterator()
        
        let next = try await iterator.next()
    }
    
    func testFullyErased() async throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        var results: [Any] = []
        
        for try await element in testSequence.fullyErased() {
            results.append(element)
        }
        
        try assertEqual(results as! [Int], testArray)
    }
}
