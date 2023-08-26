import Foundation

private enum FlattenResult<R: Sequence, InnerR> {
    case outer(R)
    case inner(UUID, InnerR)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence {
    func stream<R>(maxConcurrency: Int = .max) -> AsyncStream<R> where Element == () async -> R {
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
    
    func stream<R>(maxConcurrency: Int = .max) -> AsyncThrowingStream<R, Error> where Element == () async throws -> R {
        .init { continuation in
            let task = Task {
                await withThrowingTaskGroup(of: R.self) { group in
                    var iterator = makeIterator()
                    
                    let addTask: (inout ThrowingTaskGroup<R, Error>) -> Bool = { group in
                        if let work = iterator.next() {
                            group.addTask { try await work() }
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    for _ in 0 ..< maxConcurrency where !addTask(&group) {
                        break
                    }
                    
                    do {
                        for try await result in group {
                            continuation.yield(result)
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
    
    func flattenStream<R: Sequence, InnerR>(maxConcurrency: Int = .max) -> AsyncStream<InnerR> where Element == () async -> R, R.Element == () async -> InnerR {
        .init { continuation in
            let task = Task {
                await withTaskGroup(of: FlattenResult<R, InnerR>.self) { group in
                    var iterator = makeIterator()
                    
                    let addOuterTask: (inout TaskGroup<FlattenResult<R, InnerR>>) -> Bool = { group in
                        if let work = iterator.next() {
                            group.addTask { .outer(await work()) }
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    var innerIterators: [UUID: R.Iterator] = [:]
                    
                    let addInnerTask: (inout TaskGroup<FlattenResult<R, InnerR>>, UUID) -> Bool = { group, id in
                        if let work =  innerIterators[id]!.next() {
                            group.addTask { .inner(id, await work()) }
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    var capacity = maxConcurrency
                    
                    while capacity > 0, addOuterTask(&group) {
                        capacity -= 1
                    }
                    
                    for await result in group {
                        capacity += 1
                        
                        switch result {
                            case let .outer(outerResult):
                                let id = UUID()
                                innerIterators[id] = outerResult.makeIterator()
                                
                                while capacity > 0, addInnerTask(&group, id) {
                                    capacity -= 1
                                }
                            case let .inner(id, innerResult):
                                continuation.yield(innerResult)
                                while capacity > 0, addInnerTask(&group, id) {
                                    capacity -= 1
                                }
                        }
                        
                        if capacity > 0 {
                            _ = addOuterTask(&group)
                        }
                    }
                    
                    continuation.finish()
                }
            }
            
            continuation.onTermination = { _ in task.cancel() }
        }
    }
    
    func flattenStream<R: Sequence, InnerR>(maxConcurrency: Int = .max) -> AsyncThrowingStream<InnerR, Error> where Element == () async throws -> R, R.Element == () async throws -> InnerR {
        .init { continuation in
            let task = Task {
                await withThrowingTaskGroup(of: FlattenResult<R, InnerR>.self) { group in
                    var iterator = makeIterator()
                    
                    let addOuterTask: (inout ThrowingTaskGroup<FlattenResult<R, InnerR>, Error>) -> Bool = { group in
                        if let work = iterator.next() {
                            group.addTask { .outer(try await work()) }
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    var innerIterators: [UUID: R.Iterator] = [:]
                    
                    let addInnerTask: (inout ThrowingTaskGroup<FlattenResult<R, InnerR>, Error>, UUID) -> Bool = { group, id in
                        if let work =  innerIterators[id]!.next() {
                            group.addTask { .inner(id, try await work()) }
                            return true
                        } else {
                            return false
                        }
                    }
                    
                    var capacity = maxConcurrency
                    
                    while capacity > 0, addOuterTask(&group) {
                        capacity -= 1
                    }
                    
                    do {
                        for try await result in group {
                            capacity += 1
                            
                            switch result {
                                case let .outer(outerResult):
                                    let id = UUID()
                                    innerIterators[id] = outerResult.makeIterator()
                                    
                                    while capacity > 0, addInnerTask(&group, id) {
                                        capacity -= 1
                                    }
                                case let .inner(id, innerResult):
                                    continuation.yield(innerResult)
                                    while capacity > 0, addInnerTask(&group, id) {
                                        capacity -= 1
                                    }
                            }
                            
                            if capacity > 0 {
                                _ = addOuterTask(&group)
                            }
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
public extension Sequence where Element == () async -> Void {
    func awaitAll(maxConcurrency: Int = .max) async {
        await stream(maxConcurrency: maxConcurrency)
            .waitUntilDone()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence {
    func awaitAny<R>(maxConcurrency: Int = .max) async -> R? where Element == () async -> R {
        let stream = stream(maxConcurrency: maxConcurrency)

        for await element in stream {
            return element
        }
        
        return nil
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Element == () async throws -> Void {
    func awaitAll(maxConcurrency: Int = .max) async throws {
        try await stream(maxConcurrency: maxConcurrency)
            .waitUntilDone()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence {
    func awaitAny<R>(maxConcurrency: Int = .max) async throws -> R? where Element == () async throws -> R {
        let stream = stream(maxConcurrency: maxConcurrency)

        for try await element in stream {
            return element
        }
        
        return nil
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence {
    func flattenAwaitAll<S: Sequence>(maxConcurrency: Int = .max) async where Element == () async -> S, S.Element == () async -> Void {
        await flattenStream(maxConcurrency: maxConcurrency)
            .waitUntilDone()
    }
    
    func flattenAwaitAll<S: Sequence>(maxConcurrency: Int = .max) async throws where Element == () async throws -> S, S.Element == () async throws -> Void {
        try await flattenStream(maxConcurrency: maxConcurrency)
            .waitUntilDone()
    }
}
