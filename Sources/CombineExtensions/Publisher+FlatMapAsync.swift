import AsyncExtensions
import Combine

public struct BlahBlahError: Error {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Output: Sendable, Failure == Never {
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<R, Publishers.FlatMap<NonThrowingAsyncFuture<R>, Publishers.Map<Self, AsyncElement<R>>>> where R.Output == InnerR, R.Failure == Never {
        mapAsync(transform)
            .flatten()
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher where Output: Sendable, Failure == Never {
    func flatMapAsync<R: Publisher>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<R, Publishers.SetFailureType<Publishers.FlatMap<NonThrowingAsyncFuture<R>, Publishers.Map<Self, AsyncElement<R>>>, R.Failure>> {
        mapAsync(transform)
            .flatten()
    }

    // Causes ambiguous lookup.  Can replace the first extension in this file if we drop support for older targets
//    func flatMapAsync<R: Publisher>(
//        _ transform: @escaping @Sendable (Output) async -> R
//    ) -> Publishers.FlatMap<R, Publishers.FlatMap<NonThrowingAsyncFuture<R>, Publishers.Map<Self, AsyncElement<R>>>> where R.Failure == Never {
//        mapAsync(transform)
//            .flatten()
//    }
    
    func flatMapAsync<R: Publisher>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<R, any Error>, Publishers.FlatMap<AsyncFuture<ThrowingAsyncFutureReceiver<R>>, Publishers.SetFailureType<Publishers.Map<Self, AsyncThrowingElement<R>>, any Error>>> where R.Failure == Never {
        mapAsync(transform)
            .flatten()
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher where Output: Sendable {
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<R, Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<R>, Self.Failure>, Publishers.Map<Self, AsyncElement<R>>>> where R.Output == InnerR, R.Failure == Failure {
        mapAsync(transform)
            .flatten()
    }
    
    func flatMapAsync<R: Publisher>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<R, Failure>, Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<Publishers.SetFailureType<R, Failure>>, Failure>, Publishers.Map<Self, AsyncElement<Publishers.SetFailureType<R, Failure>>>>> where R.Failure == Never {
        mapAsync { element in await transform(element).setFailureType(to: Failure.self) }
            .flatten()
    }
    
    func flatMapAsync<R: Publisher>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<R, any Error>, Publishers.FlatMap<AsyncFuture<ThrowingAsyncFutureReceiver<R>>, Publishers.MapError<Publishers.Map<Self, AsyncThrowingElement<R>>, any Error>>> where R.Failure == Never {
        mapAsync(transform)
            .flatten()
    }
    
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<Publishers.MapError<R, any Error>, Publishers.FlatMap<ThrowingAsyncFuture<Publishers.MapError<R, any Error>>, Publishers.MapError<Publishers.Map<Self, AsyncThrowingElement<Publishers.MapError<R, any Error>>>, any Error>>> where R.Output == InnerR, R.Failure == Failure {
        mapAsync { element in try await transform(element).eraseErrorType() }
            .flatten()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Output: Sendable {
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<Publishers.MapError<R, any Error>, Publishers.FlatMap<ThrowingAsyncFuture<Publishers.MapError<R, any Error>>, Publishers.MapError<Publishers.Map<Self, AsyncThrowingElement<Publishers.MapError<R, any Error>>>, any Error>>> where R.Output == InnerR {
        mapAsync { element in try await transform(element).eraseErrorType() }
            .flatten()
    }
}
