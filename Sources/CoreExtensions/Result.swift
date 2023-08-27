//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

public extension Result {
    func eraseErrorType() -> Result<Success, Error> {
        mapError { error in error as Error }
    }
    
    func compact<InnerSuccess>() -> Result<InnerSuccess, Failure>? where Success == InnerSuccess? {
        switch self {
            case let .success(outerResult):
                return outerResult.map { result in .success(result) }
            case let .failure(error):
                return .failure(error)
        }
    }
    
    func flatten<InnerSuccess>() -> Result<InnerSuccess, Failure> where Success == Result<InnerSuccess, Failure> {
        switch self {
            case .success(let outerResult):
                return outerResult
            case .failure(let error):
                return .failure(error)
        }
    }
    
    func flatten<InnerSuccess, InnerFailure: Error>() -> Result<InnerSuccess, Error> where Success == Result<InnerSuccess, InnerFailure> {
        switch self {
            case .success(let outerResult):
                return outerResult.mapError { error in error as Error }
            case .failure(let error):
                return .failure(error)
        }
    }
    
    func compactMap<NewSuccess>(
        _ transform: (Success) -> NewSuccess?
    ) -> Result<NewSuccess, Failure>? {
        self
            .map(transform)
            .compact()
    }

    func tryMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess
    ) -> Result<NewSuccess, Error> {
        eraseErrorType()
            .flatMap { success in
                Result<NewSuccess, Error> { try transform(success) }
            }
    }

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

    func tryCompactMap<NewSuccess>(
        _ transform: (Success) throws -> NewSuccess?
    ) -> Result<NewSuccess, Error>? {
        tryMap(transform)
            .compact()
    }

    func tryFlatMap<NewSuccess, NewFailure: Error>(
        _ transform: (Success) throws -> Result<NewSuccess, NewFailure>
    ) -> Result<NewSuccess, Error> {
        eraseErrorType()
            .flatMap { success in
                Result<Result<NewSuccess, NewFailure>, Error> { try transform(success) }.flatten()
            }
    }

    func `catch`(
        _ catcher: (Failure) -> Success
    ) -> Success {
        switch self {
            case .success(let value):
                return value
            case .failure(let error):
                return catcher(error)
        }
    }

    func tryCatch(
        _ catcher: (Failure) throws -> Success
    ) -> Result<Success, Error> {
        switch self {
            case .success(let value):
                return .success(value)
            case .failure(let error):
                return Result<Success, Error> { try catcher(error) }
        }
    }
}
