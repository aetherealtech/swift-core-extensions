import Assertions
import Stubbing
import XCTest

@testable import AsyncCollectionExtensions

final class LazySequenceAsyncTests: XCTestCase {
    struct TestError: Error {}
    
    func testMap() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            2,
            3,
            4,
            5,
        ])
        
        let expectedResult = [
            "1",
            "2",
            "3",
            "4",
            "5",
        ]
        
        let result = testSequence
            .lazy
            .map { element async -> String in element.description }
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testMapThrowing() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            2,
            3,
            4,
            5,
        ])
        
        let expectedResult = [
            "1",
            "2",
            "3",
            "4",
            "5",
        ]
        
        let result = testSequence
            .lazy
            .map { element async throws -> String in element.description }
                
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
    
    func testCompactMap() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            2,
            nil,
            4,
            5,
            6,
            nil,
            nil,
            9,
            nil
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
            .compactMap { element async -> String? in element?.description }
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testCompactMapThrowing() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            2,
            nil,
            4,
            5,
            6,
            nil,
            nil,
            9,
            nil
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
            .compactMap { element async throws -> String? in element?.description }
        
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
    
    func testFlatMap() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = testSequence
            .lazy
            .flatMap { element async -> SyncDestructiveSequence<[String]> in .init(.init(repeating: element.description, count: element)) }
        
        try assertEqual(expectedResult, await result.store(in: Array.self))
    }
    
    func testFlatMapThrowing() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = testSequence
            .lazy
            .flatMap { element async throws -> SyncDestructiveSequence<[String]> in .init(.init(repeating: element.description, count: element)) }
        
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
    
    func testFlatMapAsyncInner() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = testSequence
            .lazy
            .flatMap { DestructiveSequence(Array(repeating: $0.description, count: $0)) }
        
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
    
    func testFlatMapAsyncInnerThrowing() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = testSequence
            .lazy
            .flatMap { element throws -> DestructiveSequence<[String]> in .init(.init(repeating: element.description, count: element)) }
        
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
    
    func testFlatMapAsyncInnerAsync() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = testSequence
            .lazy
            .flatMap { element async -> DestructiveSequence<[String]> in .init(.init(repeating: element.description, count: element)) }
        
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
    
    func testFlatMapAsyncInnerAsyncThrowing() async throws {
        let testSequence = SyncDestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            "1",
            "3",
            "3",
            "3",
            "2",
            "2",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "8",
            "5",
            "5",
            "5",
            "5",
            "5",
        ]
        
        let result = testSequence
            .lazy
            .flatMap { element async throws -> DestructiveSequence<[String]> in .init(.init(repeating: element.description, count: element)) }
        
        try assertEqual(expectedResult, try await result.store(in: Array.self))
    }
}
