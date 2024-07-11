import Foundation

public extension Result where Failure == Error {
    var value: Success? {
        if case let .success(value) = self {
            return value
        }
        
        return nil
    }
    
    var error: Failure? {
        if case let .failure(error) = self {
            return error
        }
        
        return nil
    }
    
    /// Identical to `Result.init(catching:)`, except the `body` can be `async`.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    init(catching body: () async throws -> Success) async {
        do {
            self = .success(try await body())
        } catch {
            self = .failure(error)
        }
    }
}

public extension Result {
    /// Returns a `Result` with the `Failure` type erased up to `any Error`, that contains the same result as the receiver.
    @inlinable
    func eraseErrorType() -> Result<Success, any Error> {
        mapError { error in error as Error }
    }
    
    /// Converts a `Result<T?, Failure>` to a `Result<T, Failure>?`, that is `nil` if and only if the original result is a successful `nil`, and contains the same result otherwise.
    @inlinable
    func compact<InnerSuccess>() -> Result<InnerSuccess, Failure>? where Success == InnerSuccess? {
        switch self {
            case let .success(outerResult): outerResult.map { result in .success(result) }
            case let .failure(error): .failure(error)
        }
    }
    
    /// Converts a `Result<Result<T, Failure>, Failure>` to a `Result<T, Failure>`, that contains a successful result if and only if both the outer and inner results are successful, and contains the failure otherwise.
    @inlinable
    func flatten<InnerSuccess>() -> Result<InnerSuccess, Failure> where Success == Result<InnerSuccess, Failure> {
        switch self {
            case .success(let outerResult): outerResult
            case .failure(let error): .failure(error)
        }
    }
    
    /// Converts a `Result<Result<T, Failure1>, Failure2>` to a `Result<T, any Error>`, that contains a successful result if and only if both the outer and inner results are successful, and contains the failure, erased up to an `any Error`, otherwise.
    @inlinable
    func flatten<InnerSuccess, InnerFailure: Error>() -> Result<InnerSuccess, Error> where Success == Result<InnerSuccess, InnerFailure> {
        switch self {
            case .success(let outerResult): outerResult.eraseErrorType()
            case .failure(let error): .failure(error)
        }
    }
    
    /// If the receiver contains a successful result, the value is mapped by the `transform`, which produces an optional result.  If the result is present, a `Result` is returned containing that successful result.  If the result is absent, `nil` is returned.  If the receiver contains an error, that error is returned.
    @inlinable
    func compactMap<NewSuccess>(
        _ transform: (Success) -> NewSuccess?
    ) -> Result<NewSuccess, Failure>? {
        self
            .map(transform)
            .compact()
    }
    
    /// The same as `Result.map(_:)`, except the `transform` can throw.  If it does, a `Result` containing the thrown error is returned.  Since a thrown error is an `any Error`, the receiver's `Failure` type must be erased up to `any Error` to be able to hold a thrown error.
    @inlinable
    func tryMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) -> Result<NewSuccess, Error> {
        eraseErrorType()
            .flatMap { success in
                Result<NewSuccess, Error> { try transform(success) }
            }
    }
    
    /// The same as `Result.mapError(_:)`, except the `transform` can throw.  If it does, a `Result` containing the thrown error is returned.  Since a thrown error is an `any Error`, the receiver's `Failure` type must be erased up to `any Error` to be able to hold a thrown error.
    @inlinable
    func tryMapError(
        _ transform: (Failure) throws -> Error
    ) -> Result<Success, Error> {
        flatMapError { error in
            do {
                return .failure(try transform(error))
            } catch let newError {
                return .failure(newError)
            }
        }
    }
    
    /// The same as ``compactMap(_:)``, except the `transform` can throw.  If it does, a `Result` containing the thrown error is returned.  Since a thrown error is an `any Error`, the receiver's `Failure` type must be erased up to `any Error` to be able to hold a thrown error.
    @inlinable
    func tryCompactMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess?
    ) -> Result<NewSuccess, Error>? {
        tryMap(transform)
            .compact()
    }
    
    /// The same as `Result.flatMap(_:)`, except the `transform` can throw.  If it does, a `Result` containing the thrown error is returned.  Since a thrown error is an `any Error`, the receiver's `Failure` type must be erased up to `any Error` to be able to hold a thrown error.
    @inlinable
    func tryFlatMap<NewSuccess, NewFailure: Error>(
        _ transform: (Success) throws -> Result<NewSuccess, NewFailure>
    ) -> Result<NewSuccess, Error> {
        eraseErrorType()
            .flatMap { success in
                Result<Result<NewSuccess, NewFailure>, Error> { try transform(success) }.flatten()
            }
    }
    
    /// If the receiver contains a successful result, that result is returned.  If the receiver contains an error, the error is converted to a succesful result with `catcher`, and that result is returned.
    @inlinable
    func `catch`(
        _ catcher: (Failure) -> Success
    ) -> Success {
        switch self {
            case .success(let value): value
            case .failure(let error): catcher(error)
        }
    }
    
    /// If the receiver contains a successful result, a `Result` with that successful result is returned.  If the receiver contains an error, the error is converted to a succesful result with `catcher`, and a `Result` with that successful result is returned.  If `catcher` throws, a `Result` is returned with the thrown error.  Since a thrown error is an `any Error`, the `Failure` type of the returned `Result` must be erased up to `any Error`.
    @inlinable
    func tryCatch(
        _ catcher: (Failure) throws -> Success
    ) -> Result<Success, Error> {
        switch self {
            case .success(let value): .success(value)
            case .failure(let error): Result<Success, Error> { try catcher(error) }
        }
    }
    
    /// Identical to `Result.map(_:)`, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func mapAsync<NewSuccess>(
        _ transform: (Success) async -> NewSuccess
    ) async -> Result<NewSuccess, Failure> {
        switch self {
            case let .success(success): .success(await transform(success))
            case let .failure(error): .failure(error)
        }
    }
    
    /// Identical to `Result.mapError(_:)`, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func mapErrorAsync<NewFailure>(
        _ transform: (Failure) async -> NewFailure
    ) async -> Result<Success, NewFailure> {
        switch self {
            case let .success(success): .success(success)
            case let .failure(error): .failure(await transform(error))
        }
    }
    
    /// Identical to `Result.flatMap(_:)`, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func flatMapAsync<NewSuccess>(
        _ transform: (Success) async -> Result<NewSuccess, Failure>
    ) async -> Result<NewSuccess, Failure> {
        switch self {
            case let .success(success): await transform(success)
            case let .failure(error): .failure(error)
        }
    }
    
    /// Identical to `Result.flatMapError(_:)`, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func flatMapErrorAsync<NewFailure>(
        _ transform: (Failure) async -> Result<Success, NewFailure>
    ) async -> Result<Success, NewFailure> where NewFailure : Error {
        switch self {
            case let .success(success): .success(success)
            case let .failure(error): await transform(error)
        }
    }
    
    /// Identical to ``compactMap(_:)``, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func compactMapAsync<NewSuccess>(
        _ transform: (Success) async -> NewSuccess?
    ) async -> Result<NewSuccess, Failure>? {
        await self
            .mapAsync(transform)
            .compact()
    }
    
    /// Identical to ``tryMap(_:)``, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func tryMapAsync<NewSuccess>(
        _ transform: (Success) async throws -> NewSuccess
    ) async -> Result<NewSuccess, Error> {
        await eraseErrorType()
            .flatMapAsync { success in
                await Result<NewSuccess, Error> { try await transform(success) }
            }
    }
    
    /// Identical to ``tryMapError(_:)``, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func tryMapErrorAsync(
        _ transform: (Failure) async throws -> Error
    ) async -> Result<Success, Error> {
        await flatMapErrorAsync { error in
            do {
                return .failure(try await transform(error))
            } catch let newError {
                return .failure(newError)
            }
        }
    }
    
    /// Identical to ``tryCompactMap(_:)``, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func tryCompactMapAsync<NewSuccess>(
        _ transform: (Success) async throws -> NewSuccess?
    ) async -> Result<NewSuccess, Error>? {
        await tryMapAsync(transform)
            .compact()
    }
    
    /// Identical to ``tryFlatMap(_:)``, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func tryFlatMapAsync<NewSuccess, NewFailure: Error>(
        _ transform: (Success) async throws -> Result<NewSuccess, NewFailure>
    ) async -> Result<NewSuccess, Error> {
        await eraseErrorType()
            .flatMapAsync { success in
                await Result<Result<NewSuccess, NewFailure>, Error> { try await transform(success) }.flatten()
            }
    }
    
    /// Identical to ``catch(_:)``, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func catchAsync(
        _ catcher: (Failure) async -> Success
    ) async -> Success {
        switch self {
            case .success(let value): value
            case .failure(let error): await catcher(error)
        }
    }
    
    /// Identical to ``tryCatch(_:)``, except the `transform` can be `async.`
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @inlinable
    func tryCatchAsync(
        _ catcher: (Failure) async throws -> Success
    ) async -> Result<Success, Error> {
        switch self {
            case .success(let value): .success(value)
            case .failure(let error): await Result<Success, Error> { try await catcher(error) }
        }
    }
}
