import AsyncExtensions
import CollectionExtensions

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
        var results = [R]()
        
        for element in self {
            if let result = try await transform(element) {
                results.append(result)
            }
        }
        
        return results
    }
    
    func flatMapAsync<R: Sequence, InnerR>(
        _ transform: @escaping (Element) async throws -> R
    ) async rethrows -> [InnerR] where R.Element == InnerR {
        var results = [InnerR]()
        
        for element in self {
            for result in try await transform(element) {
                results.append(result)
            }
        }
        
        return results
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
        var results = [InnerR]()
        
        for element in self {
            for try await result in try await transform(element) {
                results.append(result)
            }
        }
        
        return results
    }
    
    func parallelForEach(
        maxConcurrency: Int = .max,
        _ body: @escaping @Sendable (Element) async -> Void
    ) async where Element: Sendable {
        await map { element in { @Sendable in await body(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelForEach(
        maxConcurrency: Int = .max,
        _ body: @escaping @Sendable (Element) async throws -> Void
    ) async throws where Element: Sendable {
        try await map { element in { @Sendable in try await body(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelMap<R>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async -> R
    ) async -> [R] where Element: Sendable {
        await map { element in { @Sendable in await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelMap<R>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async throws -> R
    ) async throws -> [R] where Element: Sendable {
        try await map { element in { @Sendable in try await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelFlatMap<R: Collection & Sendable, InnerR>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async -> R
    ) async -> [InnerR] where Element: Sendable, R.Element == AsyncElement<InnerR> {
        await map { element in { @Sendable in await transform(element) } }
            .flattenAwaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelFlatMap<R: Collection & Sendable, InnerR>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async throws -> R
    ) async throws -> [InnerR] where Element: Sendable, R.Element == AsyncThrowingElement<InnerR> {
        try await map { element in { @Sendable in try await transform(element) } }
            .flattenAwaitAll(maxConcurrency: maxConcurrency)
    }
}
