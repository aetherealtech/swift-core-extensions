import AsyncExtensions
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    func compactMapAsync<R>(
        _ transform: @escaping @Sendable (Output) async -> R?
    ) -> Publishers.CompactMap<Publishers.FlatMap<NonThrowingAsyncFuture<R?>, Publishers.Map<Self, AsyncElement<R?>>>, R> where Output: Sendable {
        mapAsync(transform)
            .compact()
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func tryCompactMapAsync<R>(
        _ transform: @escaping @Sendable (Output) async throws -> R?
    ) -> Publishers.CompactMap<Publishers.FlatMap<ThrowingAsyncFuture<R?>, Publishers.MapError<Publishers.Map<Self, AsyncThrowingElement<R?>>, any Error>>, R> where Output: Sendable {
        mapAsync(transform)
            .compact()
    }
}
