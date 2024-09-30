import AsyncExtensions
import CollectionExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension LazySequenceProtocol {
    func map<R>(
        _ transform: @escaping @Sendable (Element) async -> R
    ) -> AsyncSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async -> R>, AsyncFunction<R>>, R> {
        map { element in { await transform(element) } }
            .await()
    }

    func map<R>(
        _ transform: @escaping @Sendable (Element) async throws -> R
    ) -> AsyncThrowingSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async throws -> R>, AsyncThrowingFunction<R>>, R> {
        map { element in { try await transform(element) } }
            .await()
    }

    func compactMap<R>(
        _ transform: @escaping @Sendable (Element) async -> R?
    ) -> AsyncCompactMapSequence<AsyncSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async -> R?>, AsyncFunction<R?>>, R?>, R> {
        map(transform)
            .compact()
    }
    
    func compactMap<R>(
        _ transform: @escaping @Sendable (Element) async throws -> R?
    ) -> AsyncCompactMapSequence<AsyncThrowingSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async throws -> R?>, AsyncThrowingFunction<R?>>, R?>, R> {
        map(transform)
            .compact()
    }
    
    func flatMap<R: Sequence, InnerR>(
        _ transform: @escaping @Sendable (Element) async -> R
    ) -> AsyncFlatMapSequence<AsyncSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async -> R>, AsyncFunction<R>>, R>, SequenceAsyncWrapper<R>> where R.Element == InnerR {
        map(transform)
            .flatten()
    }
    
    func flatMap<R: Sequence, InnerR>(
        _ transform: @escaping @Sendable (Element) async throws -> R
    ) -> AsyncFlatMapSequence<AsyncThrowingSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async throws -> R>, AsyncThrowingFunction<R>>, R>, SequenceAsyncWrapper<R>> where R.Element == InnerR {
        map(transform)
            .flatten()
    }
    
    func flatMap<R: AsyncSequence, InnerR>(
        _ transform: @escaping @Sendable (Element) async -> R
    ) -> AsyncFlatMapSequence<AsyncSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async -> R>, AsyncFunction<R>>, R>, SequenceAsyncWrapper<R>> where R.Element == InnerR {
        map(transform)
            .flatten()
    }
    
    func flatMap<R: AsyncSequence, InnerR>(
        _ transform: @escaping @Sendable (Element) async throws -> R
    ) -> AsyncFlatMapSequence<AsyncThrowingSequenceBridge<LazyMapSequence<LazyMapSequence<Self.Elements, () async throws -> R>, AsyncThrowingFunction<R>>, R>, SequenceAsyncWrapper<R>> where R.Element == InnerR {
        map(transform)
            .flatten()
    }
}
