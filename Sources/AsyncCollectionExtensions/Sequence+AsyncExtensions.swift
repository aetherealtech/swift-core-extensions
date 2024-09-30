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
        if let collection = self as? any Collection {
            results.reserveCapacity(collection.count)
        }
        
        for element in self {
            results.append(try await transform(element))
        }
        
        return results
    }
    
    func compactMapAsync<R>(
        _ transform: @escaping (Element) async throws -> R?
    ) async rethrows -> [R] {
        var results = [R]()
        if let collection = self as? any RandomAccessCollection {
            results.reserveCapacity(collection.count)
        }
        
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
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func awaitAll<R>(maxConcurrency: Int = .max) async -> [R] where Element == AsyncElement<R> {
        let collection = self
            .makeRandomAccess
  
        guard collection.count > 0 else {
            return []
        }
        
        let stream = collection
            .enumerated()
            .lazy
            .mapSendable { (offset, work) in { @Sendable in (offset, await work()) } }
            .stream(maxConcurrency: maxConcurrency)
        
        var theBuffer: UnsafeMutablePointer<R>?
        
        let result = [R](unsafeUninitializedCapacity: collection.count) { buffer, initializedCount in
            theBuffer = buffer.baseAddress.unsafelyUnwrapped
            initializedCount = collection.count
        }

        for await (offset, element) in stream {
            (theBuffer.unsafelyUnwrapped + offset).initialize(to: element)
        }

        return result
    }

    func awaitAll<R>(maxConcurrency: Int = .max) async throws -> [R] where Element == AsyncThrowingElement<R> {
        let collection = self
            .makeRandomAccess
        
        guard collection.count > 0 else {
            return []
        }
        
        let stream = collection
            .enumerated()
            .lazy
            .mapSendable { (offset, work) in { @Sendable in (offset, try await work()) } }
            .stream(maxConcurrency: maxConcurrency)
        
        var theBuffer: UnsafeMutablePointer<R>!
        
        let result = [R](unsafeUninitializedCapacity: collection.count) { buffer, initializedCount in
            theBuffer = buffer.baseAddress.unsafelyUnwrapped
            initializedCount = collection.count
        }

        for try await (offset, element) in stream {
            (theBuffer.unsafelyUnwrapped + offset).initialize(to: element)
        }

        return result
    }
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func parallelForEach(
        maxConcurrency: Int = .max,
        _ body: @escaping @Sendable (Element) async -> Void
    ) async where Element: Sendable {
        await lazy
            .mapSendable { element in { @Sendable in await body(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelForEach(
        maxConcurrency: Int = .max,
        _ body: @escaping @Sendable (Element) async throws -> Void
    ) async throws where Element: Sendable {
        try await lazy
            .mapSendable { element in { @Sendable in try await body(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelMap<R>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async -> R
    ) async -> [R] where Element: Sendable {
        await lazy
            .mapSendable { element in { @Sendable in await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelMap<R>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async throws -> R
    ) async throws -> [R] where Element: Sendable {
        try await lazy
            .mapSendable { element in { @Sendable in try await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
    }
    
    func parallelCompactMap<R>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async -> R?
    ) async -> [R] where Element: Sendable {
        await lazy
            .mapSendable { element in { @Sendable in await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
            .compact()
    }
    
    func parallelCompactMap<R>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async throws -> R?
    ) async throws -> [R] where Element: Sendable {
        try await lazy
            .mapSendable { element in { @Sendable in try await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
            .compact()
    }
    
    func parallelFlatMap<R: Collection & Sendable, InnerR>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async -> R
    ) async -> [InnerR] where Element: Sendable, R.Element == InnerR {
        await map { element in { @Sendable in await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
            .flatten()
    }
    
    func parallelFlatMap<R: Collection & Sendable, InnerR>(
        maxConcurrency: Int = .max,
        _ transform: @escaping @Sendable (Element) async throws -> R
    ) async throws -> [InnerR] where Element: Sendable, R.Element == InnerR {
        try await map { element in { @Sendable in try await transform(element) } }
            .awaitAll(maxConcurrency: maxConcurrency)
            .flatten()
    }
    
    func parallelFilter(
        maxConcurrency: Int = .max,
        _ condition: @escaping @Sendable (Element) async -> Bool
    ) async -> [Element] where Element: Sendable {
        await parallelCompactMap { element in await condition(element) ? element : nil }
    }
    
    func parallelFilter(
        maxConcurrency: Int = .max,
        _ condition: @escaping @Sendable (Element) async throws -> Bool
    ) async throws -> [Element] where Element: Sendable {
        try await parallelCompactMap { element in try await condition(element) ? element : nil }
    }
}
