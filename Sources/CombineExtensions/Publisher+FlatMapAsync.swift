import AsyncExtensions
import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<R, Publishers.FlatMap<NonThrowingAsyncFuture<R>, Publishers.Map<Self, AsyncElement<R>>>> where Output: Sendable, R.Output == InnerR, R.Failure == Never {
        mapAsync(transform)
            .flatten()
    }
    
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping (Output) -> R
    ) -> Publishers.FlatMap<NonThrowingAsyncFuture<InnerR>, Publishers.FlatMap<R, Self>> where Output: Sendable, R.Output == AsyncElement<InnerR>, R.Failure == Never {
        flatMap(transform)
            .await()
    }

    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<NonThrowingAsyncFuture<InnerR>, Publishers.FlatMap<R, Publishers.FlatMap<NonThrowingAsyncFuture<R>, Publishers.Map<Self, AsyncElement<R>>>>> where Output: Sendable, R.Output == AsyncElement<InnerR>, R.Failure == Never {
        mapAsync(transform)
            .flatten()
            .await()
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher {
    func flatMapAsync<R: Publisher & Sendable, InnerR>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<R, Publishers.FlatMap<Publishers.SetFailureType<AsyncFuture<NonThrowingAsyncFutureReceiver<R>>, Self.Failure>, Publishers.Map<Self, @Sendable () async -> R>>> where Output: Sendable, R.Output == InnerR, R.Failure == Failure {
        mapAsync(transform)
            .flatten()
    }

    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping (Output) -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<InnerR>, Self.Failure>, Publishers.FlatMap<R, Self>> where R.Output == AsyncElement<InnerR>, R.Failure == Failure {
        flatMap(transform)
            .await()
    }

    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<InnerR>, Self.Failure>, Publishers.FlatMap<R, Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<R>, Self.Failure>, Publishers.Map<Self, AsyncElement<R>>>>> where Output: Sendable, R.Output == AsyncElement<InnerR>, R.Failure == Failure {
        mapAsync(transform)
            .flatten()
            .await()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<Publishers.MapError<R, any Error>, Publishers.FlatMap<ThrowingAsyncFuture<Publishers.MapError<R, any Error>>, Publishers.MapError<Publishers.Map<Self, AsyncThrowingElement<Publishers.MapError<R, any Error>>>, any Error>>> where Output: Sendable, R.Output == InnerR, R.Failure == Never {
        mapAsync { element in try await transform(element).eraseErrorType() }
            .flatten()
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher {
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping (Output) throws -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<InnerR>, any Error>, Publishers.FlatMap<Publishers.MapError<R, any Error>, Publishers.TryMap<Self, Publishers.MapError<R, any Error>>>> where R.Output == AsyncElement<InnerR> {
        tryMap { element in try transform(element).eraseErrorType() }
            .flatten()
            .await()
    }
    
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping (Output) -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<InnerR>, any Error>, Publishers.FlatMap<R, Publishers.MapError<Self, any Error>>> where R.Output == AsyncElement<InnerR>, R.Failure == Error {
        eraseErrorType()
            .flatMap(transform)
            .await()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Error {
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<R, Publishers.FlatMap<ThrowingAsyncFuture<R>, Publishers.Map<Self, AsyncThrowingElement<R>>>> where Output: Sendable, R.Output == InnerR {
        mapAsync(transform)
            .flatten()
    }
    
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<R, Publishers.FlatMap<ThrowingAsyncFuture<R>, Publishers.Map<Self, AsyncThrowingElement<R>>>> where Output: Sendable, R.Output == InnerR {
        mapAsync(transform)
            .flatten()
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher where Failure == Error {
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping (Output) -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<InnerR>, any Error>, Publishers.FlatMap<Publishers.SetFailureType<R, any Error>, Self>> where R.Output == AsyncElement<InnerR> {
        flatMap(transform)
            .await()
    }
    
    func flatMapAsync<R: Publisher, InnerR>(
        _ transform: @escaping (Output) throws -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<NonThrowingAsyncFuture<InnerR>, any Error>, Publishers.FlatMap<Publishers.MapError<R, any Error>, Publishers.TryMap<Self, Publishers.MapError<R, any Error>>>> where R.Output == AsyncElement<InnerR> {
        tryMap { element in try transform(element).eraseErrorType() }
            .flatten()
            .await()
    }
}
