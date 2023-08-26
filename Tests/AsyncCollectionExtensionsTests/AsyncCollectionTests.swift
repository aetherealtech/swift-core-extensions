import XCTest

import AsyncExtensions
@testable import AsyncCollectionExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class AsyncCollectionTests: XCTestCase {
    func testAwaitAll() async throws {
        print("Let's Go")
        
        let results = await (0..<50)
            .map { index in
                {
                    print("STARTING \(index)")
                    try! await Task.sleep(timeInterval: 1.0)
                    print("ENDING \(index)")
                    
                    return "VALUE: \(index)"
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
    
    func testAwaitAllThrowing() async throws {
        print("Let's Go")
        
        let results = try await (0..<50)
            .map { index in
                {
                    print("STARTING \(index)")
                    try await Task.sleep(timeInterval: 1.0)
                    print("ENDING \(index)")
                    
                    return "VALUE: \(index)"
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
    
    func testParallelMap() async throws {
        print("Let's Go")
        
        let results = await (0..<50)
            .parallelMap(maxConcurrency: 5) { index in
                print("PROCESSING: \(index)")
                try! await Task.sleep(timeInterval: 1.0)
                return "VALUE: \(index)"
            }
        
        print("All Done")
    }
    
    func testParallelFlatMap() async throws {
        print("Let's Go")
        
        let results = await (0..<10)
            .parallelFlatMap(maxConcurrency: 5) { outerIndex in
                print("PROCESSING OUTER: \(outerIndex)")
                try! await Task.sleep(timeInterval: 1.0)
                
                return (0..<10)
                    .map { innerIndex in
                        {
                            print("PROCESSING INNER: \(innerIndex)")
                            try! await Task.sleep(timeInterval: 1.0)
                            return "VALUE: \(outerIndex)-\(innerIndex)"
                        }
                    }
            }
        
        print("All Done")
    }
}
