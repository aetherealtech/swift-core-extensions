import XCTest

@testable import AsyncCollectionExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class AsyncSequenceTests: XCTestCase {

    func testAwaitAll() async throws {
        print("Let's Go")
        
        await (0..<50)
            .map { index in
                {
                    print("STARTING \(index)")
                    try! await Task.sleep(nanoseconds: UInt64(1e9))
                    print("ENDING \(index)")
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
    
    func testAwaitAllThrowing() async throws {
        print("Let's Go")
        
        try await (0..<50)
            .map { index in
                {
                    print("STARTING \(index)")
                    try await Task.sleep(nanoseconds: UInt64(1e9))
                    print("ENDING \(index)")
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
    
    func testAwaitAllReturn() async throws {
        print("Let's Go")
        
        let results = await (0..<50)
            .map { index in
                {
                    print("STARTING \(index)")
                    try! await Task.sleep(nanoseconds: UInt64(1e9))
                    print("ENDING \(index)")
                    
                    return "VALUE: \(index)"
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
    
    func testAwaitAllReturnThrowing() async throws {
        print("Let's Go")
        
        try await (0..<50)
            .map { index in
                {
                    print("STARTING \(index)")
                    try await Task.sleep(nanoseconds: UInt64(1e9))
                    print("ENDING \(index)")
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
    
    func testParallelMap() async throws {
        print("Let's Go")
        
        let results = await (0..<50)
            .parallelMap { index in
                print("PROCESSING: \(index)")
                try! await Task.sleep(nanoseconds: UInt64(1e9))
                return "VALUE: \(index)"
            }
        
        print("All Done")
    }
}
