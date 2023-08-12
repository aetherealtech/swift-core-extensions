import CollectionExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension LazySequenceProtocol {
    func map<R>(
        _ transform: @escaping (Element) async -> R
    ) async -> AsyncSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async -> R>, AsyncFunction<R>>, R> {
        map { element in { await transform(element) } }
            .await()
    }

    func map<R>(
        _ transform: @escaping (Element) async throws -> R
    ) async -> AsyncThrowingSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async throws -> R>, AsyncThrowingFunction<R>>, R> {
        map { element in { try await transform(element) } }
            .await()
    }

    func compactMap<R>(
        _ transform: @escaping (Element) async -> R?
    ) async -> AsyncCompactMapSequence<AsyncSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async -> R?>, AsyncFunction<R?>>, R?>, R> {
        await map(transform)
            .compact()
    }
    
    func compactMap<R>(
        _ transform: @escaping (Element) async throws -> R?
    ) async -> AsyncCompactMapSequence<AsyncThrowingSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async throws -> R?>, AsyncThrowingFunction<R?>>, R?>, R> {
        await map(transform)
            .compact()
    }
//
//    func flatMapAsync<R: Sequence, InnerR>(
//        _ transform: @escaping (Element) async throws -> R
//    ) async rethrows -> [InnerR] where R.Element == InnerR {
//        try await mapAsync(transform)
//            .flatten()
//    }
//
//    func flattenAsync<InnerElement>() async throws -> [InnerElement] where Element: AsyncSequence, Element.Element == InnerElement {
//        var results = [InnerElement]()
//
//        for element in self {
//            for try await innerElement in element {
//                results.append(innerElement)
//            }
//        }
//
//        return results
//    }
//
//    func flatMapAsync<R: AsyncSequence, InnerR>(
//        _ transform: @escaping (Element) async throws -> R
//    ) async throws -> [InnerR] where R.Element == InnerR {
//        try await mapAsync(transform)
//            .flattenAsync()
//    }
//
//    func parallelForEach(
//        maxConcurrency: Int = .max,
//        _ body: @escaping (Element) async -> Void
//    ) async {
//        await map { element in { await body(element) } }
//            .awaitAll(maxConcurrency: maxConcurrency)
//    }
//
//    func parallelForEach(
//        maxConcurrency: Int = .max,
//        _ body: @escaping (Element) async throws -> Void
//    ) async throws {
//        try await map { element in { try await body(element) } }
//            .awaitAll(maxConcurrency: maxConcurrency)
//    }
//
//    func parallelMap<R>(
//        maxConcurrency: Int = .max,
//        _ transform: @escaping (Element) async -> R
//    ) async -> [R] {
//        await map { element in { await transform(element) } }
//            .awaitAll(maxConcurrency: maxConcurrency)
//    }
//
//    func parallelMap<R>(
//        maxConcurrency: Int = .max,
//        _ transform: @escaping (Element) async throws -> R
//    ) async throws -> [R] {
//        try await map { element in { try await transform(element) } }
//            .awaitAll(maxConcurrency: maxConcurrency)
//    }
}
