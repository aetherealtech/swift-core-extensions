import XCTest

@testable import AsyncExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TaskSequenceTests: XCTestCase {

    func testStream() async throws {
        print("Let's Go")
        
        let stream = (0..<50)
            .map { index in
                { @Sendable in
                    try! await Task.sleep(timeInterval: 1.0)
                    return index
                }
            }
            .stream(maxConcurrency: 5)
        
        for await index in stream {
            print("RECEIVING: \(index)")
        }
        
        print("All Done")
    }
    
    func testThrowingStream() async throws {
        print("Let's Go")
        
        let stream = (0..<50)
            .map { index in
                { @Sendable in
                    try await Task.sleep(timeInterval: 1.0)
                    return index
                }
            }
            .stream(maxConcurrency: 5)
        
        for try await index in stream {
            print("RECEIVING: \(index)")
        }
        
        print("All Done")
    }
    
    func testFlattenStream() async throws {
        print("Let's Go")
        
        let stream = (0..<50)
            .map { outerIndex in
                { @Sendable in
                    try! await Task.sleep(timeInterval: 1.0)

                    return (0..<10)
                        .map { innerIndex in
                            { @Sendable in
                                try! await Task.sleep(timeInterval: 1.0)
                                return "\(outerIndex)-\(innerIndex)"
                            }
                        }
                }
            }
            .flattenStream(maxConcurrency: 5)
        
        for await index in stream {
            print("RECEIVING: \(index)")
        }
        
        print("All Done")
    }
    
    func testAwaitAll() async throws {
        print("Let's Go")
        
        await (0..<50)
            .map { index in
                { @Sendable in
                    print("STARTING \(index)")
                    try! await Task.sleep(timeInterval: 1.0)
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
                { @Sendable in
                    print("STARTING \(index)")
                    try await Task.sleep(timeInterval: 1.0)
                    print("ENDING \(index)")
                }
            }
            .awaitAll(maxConcurrency: 5)
        
        print("All Done")
    }
}
