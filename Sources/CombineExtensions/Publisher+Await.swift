import AsyncExtensions
import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    func await<R>() -> Publishers.FlatMap<Future<R, Never>, Self> where Output == @Sendable () async -> R {
        flatMap { work in
            Future(executing: work)
        }
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher {
    func await<R>() -> Publishers.FlatMap<Publishers.SetFailureType<Future<R, Never>, Self.Failure>, Self> where Output == @Sendable () async -> R {
        flatMap { work in
            Future(executing: work)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Error {
    func await<R>() -> Publishers.FlatMap<Future<R, Error>, Self> where Output == @Sendable () async throws -> R {
        flatMap { work in
            Future(executing: work)
        }
    }
}
