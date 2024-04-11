import AsyncExtensions
import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    func await<R>() -> Publishers.FlatMap<AsyncFuture<R, Never>, Self> where Output == @Sendable () async -> R {
        flatMap { work in
            AsyncFuture(work)
        }
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher {
    func await<R>() -> Publishers.FlatMap<Publishers.SetFailureType<AsyncFuture<R, Never>, Self.Failure>, Self> where Output == @Sendable () async -> R {
        flatMap { work in
            AsyncFuture(work)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == any Error {
    func await<R>() -> Publishers.FlatMap<AsyncFuture<R, any Error>, Self> where Output == @Sendable () async throws -> R {
        flatMap { work in
            AsyncFuture(work)
        }
    }
}
