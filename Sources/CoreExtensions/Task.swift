//
// Created by Daniel Coleman on 2/19/22.
//

import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task {

    public func map<Result>(_ transform: @escaping (Success) throws -> Result) -> Task<Result, Error> {

        Task<Result, Error> {

            try transform(try await self.value)
        }
    }

    public func map<Result>(_ transform: @escaping (Success) -> Result) -> Task<Result, Error> where Failure == Error {

        Task<Result, Error> {

            transform(try await self.value)
        }
    }

    public func map<Result>(_ transform: @escaping (Success) -> Result) -> Task<Result, Never> where Failure == Never {

        Task<Result, Never> {

            transform(await self.value)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task {

    public func flatMap<Result>(_ transform: @escaping (Success) async throws -> Result) -> Task<Result, Error> {

        Task<Result, Error> {

            try await transform(try await self.value)
        }
    }

    public func flatMap<Result>(_ transform: @escaping (Success) async -> Result) -> Task<Result, Error> where Failure == Error {

        Task<Result, Error> {

            await transform(try await self.value)
        }
    }

    public func flatMap<Result>(_ transform: @escaping (Success) async -> Result) -> Task<Result, Never> where Failure == Never {

        Task<Result, Never> {

            await transform(await self.value)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task {

    public func combine<Other, OtherFailure>(
        _ other: Task<Other, OtherFailure>
    ) -> Task<(Success, Other), Error> {

        Task<(Success, Other), Error> {

            (try await self.value, try await other.value)
        }
    }

    public func combine<Other1, OtherFailure1, Other2, OtherFailure2>(
        _ other1: Task<Other1, OtherFailure1>,
        _ other2: Task<Other2, OtherFailure2>
    ) -> Task<(Success, Other1, Other2), Error> {

        self.combine(other1)
                .combine(other2)
                .map { (first, last) in (first.0, first.1, last) }
    }

    public func combine<Other1, OtherFailure1, Other2, OtherFailure2, Other3, OtherFailure3>(
        _ other1: Task<Other1, OtherFailure1>,
        _ other2: Task<Other2, OtherFailure2>,
        _ other3: Task<Other3, OtherFailure3>
    ) -> Task<(Success, Other1, Other2, Other3), Error> {

        self.combine(other1, other2)
                .combine(other3)
                .map { (first, last) in (first.0, first.1, first.2, last) }
    }

    public func combine<Other1, OtherFailure1, Other2, OtherFailure2, Other3, OtherFailure3, Other4, OtherFailure4>(
        _ other1: Task<Other1, OtherFailure1>,
        _ other2: Task<Other2, OtherFailure2>,
        _ other3: Task<Other3, OtherFailure3>,
        _ other4: Task<Other4, OtherFailure4>
    ) -> Task<(Success, Other1, Other2, Other3, Other4), Error> {

        self.combine(other1, other2, other3)
                .combine(other4)
                .map { (first, last) in (first.0, first.1, first.2, first.3, last) }
    }

    public func combine<Other>(
        _ other: Task<Other, Never>
    ) -> Task<(Success, Other), Never> where Failure == Never {

        Task<(Success, Other), Never> {

            (await self.value, await other.value)
        }
    }

    public func combine<Other1, Other2>(
        _ other1: Task<Other1, Never>,
        _ other2: Task<Other2, Never>
    ) -> Task<(Success, Other1, Other2), Never> where Failure == Never {

        self.combine(other1)
                .combine(other2)
                .map { (first, last) in (first.0, first.1, last) }
    }

    public func combine<Other1, Other2, Other3>(
        _ other1: Task<Other1, Never>,
        _ other2: Task<Other2, Never>,
        _ other3: Task<Other3, Never>
    ) -> Task<(Success, Other1, Other2, Other3), Never> where Failure == Never {

        self.combine(other1, other2)
                .combine(other3)
                .map { (first, last) in (first.0, first.1, first.2, last) }
    }

    public func combine<Other1, Other2, Other3, Other4>(
        _ other1: Task<Other1, Never>,
        _ other2: Task<Other2, Never>,
        _ other3: Task<Other3, Never>,
        _ other4: Task<Other4, Never>
    ) -> Task<(Success, Other1, Other2, Other3, Other4), Never> where Failure == Never {

        self.combine(other1, other2, other3)
                .combine(other4)
                .map { (first, last) in (first.0, first.1, first.2, first.3, last) }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Collection {

    public func combine<Result>() -> Task<[Result], Error> where Element == Task<Result, Error>  {

        Task { try await self.awaitAll() }
    }

    public func combine<Result>() -> Task<[Result], Never> where Element == Task<Result, Never>  {

        Task { await self.awaitAll() }
    }

    public func awaitAll<Result>() async throws -> [Result] where Element == Task<Result, Error> {

        try await tryAwaitAll()
    }

    public func awaitAll<Result>() async -> [Result] where Element == Task<Result, Never> {

        try! await tryAwaitAll()
    }

    private func tryAwaitAll<Result, Failure>() async throws -> [Result] where Element == Task<Result, Failure> {

        var results = (0..<self.count).map { _ in nil as Result? }

        for (index, task) in self.enumerated() {

            let result = try await task.value
            results[index] = result
        }

        return results.compact()
    }
}