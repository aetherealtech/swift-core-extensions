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

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher {
    func compactMapAsync<R>(
        _ transform: @escaping @Sendable (Output) async -> R?
    ) -> Publishers.CompactMap<Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<R?>, Self.Failure>, Publishers.Map<Self, AsyncElement<R?>>>, R> where Output: Sendable {
        mapAsync(transform)
            .compact()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == any Error {
    func compactMapAsync<R>(
        _ transform: @escaping @Sendable (Output) async throws -> R?
    ) -> Publishers.CompactMap<Publishers.FlatMap<ThrowingAsyncFuture<R?>, Publishers.Map<Self, AsyncThrowingElement<R?>>>, R> where Output: Sendable {
        mapAsync(transform)
            .compact()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    func compactMapAsync<R>(
        _ transform: @escaping @Sendable (Output) async throws -> R?
    ) -> Publishers.CompactMap<Publishers.FlatMap<ThrowingAsyncFuture<R?>, Publishers.SetFailureType<Publishers.Map<Self, AsyncThrowingElement<R?>>, any Error>>, R> where Output: Sendable {
        mapAsync(transform)
            .compact()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func compactMapAsync<R>(
        _ transform: @escaping @Sendable (Output) async throws -> R?
    ) -> Publishers.CompactMap<Publishers.FlatMap<ThrowingAsyncFuture<R?>, Publishers.MapError<Publishers.Map<Self, AsyncThrowingElement<R?>>, any Error>>, R> where Output: Sendable {
        mapAsync(transform)
            .compact()
    }
}
