import AsyncExtensions
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Output: Sendable, Failure == Never {
    func mapAsync<R>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<AsyncFuture<R, Never>, Publishers.Map<Self, AsyncElement<R>>> {
        map { value in { @Sendable in await transform(value) } }
            .await()
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher {
    func mapAsync<R>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<AsyncFuture<R, Never>, Self.Failure>, Publishers.Map<Self, AsyncElement<R>>> where Output: Sendable {
        map { value in { @Sendable in await transform(value) } }
            .await()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func mapAsync<R>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<AsyncFuture<R, any Error>, Publishers.MapError<Publishers.Map<Self, AsyncThrowingElement<R>>, any Error>> where Output: Sendable {
        map { value in { @Sendable in try await transform(value) } }
            .eraseErrorType()
            .await()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Error {
    func mapAsync<R>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<AsyncFuture<R, any Error>, Publishers.Map<Self, AsyncThrowingElement<R>>> where Output: Sendable {
        map { value in { @Sendable in try await transform(value) } }
            .await()
    }
}
