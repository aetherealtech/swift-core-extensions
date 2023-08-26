import Combine

// Opaque type crashes compiler (particularly when used in flatMapAsync operators)

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    func mapAsync<R>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<Future<R, Never>, Publishers.Map<Self, @Sendable () async -> R>> {
        map { value in { @Sendable in await transform(value) } }
            .await()
    }
}

@available(macOS 11.0, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func mapAsync<R>(
        _ transform: @escaping @Sendable (Output) async -> R
    ) -> Publishers.FlatMap<Publishers.SetFailureType<Future<R, Never>, Self.Failure>, Publishers.Map<Self, @Sendable () async -> R>> {
        map { value in { @Sendable in await transform(value) } }
            .await()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func mapAsync<R>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<Future<R, any Error>, Publishers.MapError<Publishers.Map<Self, @Sendable () async throws -> R>, any Error>> {
        map { value in { @Sendable in try await transform(value) } }
            .eraseErrorType()
            .await()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Error {
    func mapAsync<R>(
        _ transform: @escaping @Sendable (Output) async throws -> R
    ) -> Publishers.FlatMap<Future<R, any Error>, Publishers.Map<Self, @Sendable () async throws -> R>> {
        map { value in { @Sendable in try await transform(value) } }
            .await()
    }
}
