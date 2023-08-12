import CollectionExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Element == () async -> Void {
    func awaitAll(maxConcurrency: Int = .max) async {
        await withTaskGroup(of: Void.self) { group in
            var iterator = makeIterator()
            
            let addTask: (inout TaskGroup<Void>) -> Bool = { group in
                if let work = iterator.next() {
                    group.addTask { await work() }
                    return false
                } else {
                    return true
                }
            }
            
            for _ in 0 ..< maxConcurrency {
                if addTask(&group) { break }
            }
            
            for await _ in group {
                _ = addTask(&group)
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Element == () async throws -> Void {
    func awaitAll(maxConcurrency: Int = .max) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            var iterator = makeIterator()
            
            let addTask: (inout ThrowingTaskGroup<Void, Error>) -> Bool = { group in
                if let work = iterator.next() {
                    group.addTask { try await work() }
                    return false
                } else {
                    return true
                }
            }
            
            for _ in 0 ..< maxConcurrency {
                if addTask(&group) { break }
            }
 
            for try await _ in group {
                _ = addTask(&group)
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence {
    func forEachAsync(_ body: (Element) async throws -> Void) async rethrows {
        for element in self {
            try await body(element)
        }
    }
    
    func mapAsync<R>(
        _ transform: @escaping (Element) async throws -> R
    ) async rethrows -> [R] {
        var results = [R]()
        
        for element in self {
            results.append(try await transform(element))
        }
        
        return results
    }
    
    func compactMapAsync<R>(
        _ transform: @escaping (Element) async throws -> R?
    ) async rethrows -> [R] {
        try await mapAsync(transform)
            .compact()
    }
    
    func flatMapAsync<R: Sequence, InnerR>(
        _ transform: @escaping (Element) async throws -> R
    ) async rethrows -> [InnerR] where R.Element == InnerR {
        try await mapAsync(transform)
            .flatten()
    }
    
    func flattenAsync<InnerElement>() async throws -> [InnerElement] where Element: AsyncSequence, Element.Element == InnerElement {
        var results = [InnerElement]()
        
        for element in self {
            for try await innerElement in element {
                results.append(innerElement)
            }
        }
        
        return results
    }
    
    func flatMapAsync<R: AsyncSequence, InnerR>(
        _ transform: @escaping (Element) async throws -> R
    ) async throws -> [InnerR] where R.Element == InnerR {
        try await mapAsync(transform)
            .flattenAsync()
    }
    
    func parallelForEach(
        maxConcurrency: Int = .max,
        _ body: @escaping (Element) async -> Void
    ) async {
        await map { element in { await body(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelForEach(
        maxConcurrency: Int = .max,
        _ body: @escaping (Element) async throws -> Void
    ) async throws {
        try await map { element in { try await body(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelMap<R>(
        maxConcurrency: Int = .max,
        _ transform: @escaping (Element) async -> R
    ) async -> [R] {
        await map { element in { await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelMap<R>(
        maxConcurrency: Int = .max,
        _ transform: @escaping (Element) async throws -> R
    ) async throws -> [R] {
        try await map { element in { try await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
}
