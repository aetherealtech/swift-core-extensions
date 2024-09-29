import Foundation
import ResultExtensions

public typealias AsyncElement<R> = @Sendable () async -> R
public typealias AsyncThrowingElement<R> = @Sendable () async throws -> R

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func stream<R>(maxConcurrency: Int = .max) -> AsyncStream<R> where Element == AsyncElement<R> {
        .init { continuation in
            let task = Task {
                await withTaskGroup(of: Void.self) { group in
                    var iterator = makeIterator()
                    
                    let addTask: (inout TaskGroup<Void>) -> Bool = { group in
                        if let work = iterator.next() {
                            group.addTask { continuation.yield(await work()) }
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    for _ in 0 ..< maxConcurrency where !addTask(&group) {
                        break
                    }
                    
                    for await _ in group {
                        _ = addTask(&group)
                    }
                    
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { _ in task.cancel() }
        }
    }
    
    func stream<R>(maxConcurrency: Int = .max) -> AsyncThrowingStream<R, Error> where Element == AsyncThrowingElement<R> {
        .init { continuation in
            let task = Task {
                await withThrowingTaskGroup(of: Void.self) { group in
                    var iterator = makeIterator()
                    
                    let addTask: (inout ThrowingTaskGroup<Void, any Error>) -> Bool = { group in
                        if let work = iterator.next() {
                            group.addTask { continuation.yield(try await work()) }
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    for _ in 0 ..< maxConcurrency where !addTask(&group) {
                        break
                    }
                    
                    do {
                        for try await _ in group {
                            _ = addTask(&group)
                        }
                        
                        continuation.finish()
                    } catch {
                        group.cancelAll()
                        continuation.finish(throwing: error)
                    }
                }
            }
            
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence where Element == Void {
    func waitUntilDone() async rethrows {
        for try await _ in self {}
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable, Element == AsyncElement<Void> {
    func awaitAll(maxConcurrency: Int = .max) async {
        await stream(maxConcurrency: maxConcurrency)
            .waitUntilDone()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func awaitAny<R>(maxConcurrency: Int = .max) async -> R? where Element == AsyncElement<R> {
        let stream = stream(maxConcurrency: maxConcurrency)

        for await element in stream {
            return element
        }
        
        return nil
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func awaitAny(maxConcurrency: Int = .max) async where Element == AsyncElement<Void> {
        let _: Void? = await awaitAny(maxConcurrency: maxConcurrency)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable, Element == AsyncThrowingElement<Void> {
    func awaitAll(maxConcurrency: Int = .max) async throws {
        try await stream(maxConcurrency: maxConcurrency)
            .waitUntilDone()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func awaitAny<R>(maxConcurrency: Int = .max) async throws -> R? where Element == AsyncThrowingElement<R> {
        let stream = stream(maxConcurrency: maxConcurrency)

        for try await element in stream {
            return element
        }
        
        return nil
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func awaitAny(maxConcurrency: Int = .max) async throws where Element == AsyncThrowingElement<Void> {
        let _: Void? = try await awaitAny(maxConcurrency: maxConcurrency)
    }
}
