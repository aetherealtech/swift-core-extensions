//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension Result where Failure == Error {

    public static func evaluate(_ function: () throws -> Success) -> Result {

        do {

            return .success(try function())

        } catch (let error) {

            return .failure(error)
        }
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static func evaluate(_ function: () async throws -> Success) async -> Result {

        do {

            return .success(try await function())

        } catch (let error) {

            return .failure(error)
        }
    }
}

extension Result {

    public func flatten<InnerSuccess, InnerFailure: Error>() -> Result<InnerSuccess, Error> where Success == Result<InnerSuccess, InnerFailure> {

        switch self {

        case .success(let outerResult):
            return outerResult.mapError { error in error as Error }

        case .failure(let error):
            return .failure(error)
        }
    }

    public func tryMap<NewSuccess>(
        _ transform: @escaping (Success) throws -> NewSuccess
    ) -> Result<NewSuccess, Error> {

        self
            .mapError { error in error as Error }
            .flatMap { success in

                Result<NewSuccess, Error>.evaluate { try transform(success) }
            }
    }

    public func tryMapError(
        _ transform: @escaping (Failure) throws -> Error
    ) -> Result<Success, Error> {

        self
            .flatMapError { error in

                do {

                    return .failure(try transform(error))

                } catch(let newError) {

                    return .failure(newError)
                }
            }
    }

    public func tryFlatMap<NewSuccess, NewFailure: Error>(
        _ transform: @escaping (Success) throws -> Result<NewSuccess, NewFailure>
    ) -> Result<NewSuccess, Error> {

        self
            .mapError { error in error as Error }
            .flatMap { success in Result<Result<NewSuccess, NewFailure>, Error>.evaluate { try transform(success) }.flatten() }
    }

    public func `catch`(
        _ catcher: @escaping (Failure) -> Success
    ) -> Success {

        switch self {

        case .success(let value):
            return value

        case .failure(let error):
            return catcher(error)
        }
    }

    public func tryCatch(
        _ catcher: @escaping (Failure) throws -> Success
    ) -> Result<Success, Error> {

        switch self {

        case .success(let value):
            return .success(value)

        case .failure(let error):
            return Result<Success, Error>.evaluate { try catcher(error) }
        }
    }
}
