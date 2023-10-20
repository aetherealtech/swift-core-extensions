import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task: Cancellable {}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension TimeInterval: DurationProtocol {
    public static func * (lhs: TimeInterval, rhs: Int) -> TimeInterval {
        lhs * Self(rhs)
    }
    
    public static func / (lhs: TimeInterval, rhs: Int) -> TimeInterval {
        lhs / Self(rhs)
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
extension Date: InstantProtocol {
    public func duration(to other: Date) -> TimeInterval {
        other.timeIntervalSince(self)
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *)
struct FoundationClock: Clock {
    typealias Duration = TimeInterval
    typealias Instant = Date
    
    var now: Date { .init() }
    
    var minimumResolution: TimeInterval { 1e-9 }
    
    func sleep(until deadline: Date, tolerance: TimeInterval?) async throws {
        let nanoseconds = UInt64((now.duration(to: deadline)) * 1e9)
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Task where Success == Never, Failure == Never {
    /// Convenience sleep function in terms of *TimeInterval* (seconds)
    static func sleep(timeInterval: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(timeInterval * 1e9))
    }
    
    static func sleep(until date: Date) async throws {
        try await sleep(timeInterval: date.timeIntervalSince(.init()))
    }
}

public struct TimedOut: Error {}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public func withTimeout<R: Sendable>(
    after duration: Duration,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await withTimeout(
        sleep: { try await Task.sleep(for: duration) },
        work
    )
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func withTimeout<R: Sendable>(
    timeInterval timeout: TimeInterval,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await withTimeout(
        sleep: { try await Task.sleep(timeInterval: timeout) },
        work
    )
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func withTimeout<R: Sendable>(
    at date: Date,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await withTimeout(
        sleep: { try await Task.sleep(until: date) },
        work
    )
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public func withTimeout<R: Sendable, C: Clock>(
    at instant: C.Instant,
    tolerance: C.Duration? = nil,
    clock: C,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await withTimeout(
        sleep: { try await Task.sleep(until: instant, tolerance: tolerance, clock: clock) },
        work
    )
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
fileprivate func withTimeout<R: Sendable>(
    sleep: @escaping @Sendable () async throws -> Void,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @escaping @Sendable () async throws -> R
) async throws -> R {
    try await [
        work,
        { @Sendable in
            try await sleep()
            throw TimedOut()
        }
    ].awaitAny()!
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task {
    public func finish() async throws -> Void where Success == Void, Failure == Error {

        _ = try await value
    }

    public func finish() async -> Void where Success == Void, Failure == Never {

        _ = await value
    }

    public func map<Result>(_ transform: @escaping @Sendable (Success) throws -> Result) -> Task<Result, Error> {

        Task<Result, Error> {

            try transform(try await self.value)
        }
    }

    public func map<Result>(_ transform: @escaping @Sendable (Success) -> Result) -> Task<Result, Error> where Failure == Error {

        Task<Result, Error> {

            transform(try await self.value)
        }
    }

    public func map<Result>(_ transform: @escaping @Sendable (Success) -> Result) -> Task<Result, Never> where Failure == Never {

        Task<Result, Never> {

            transform(await self.value)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task {

    public func flatMap<Result>(_ transform: @escaping @Sendable (Success) async throws -> Result) -> Task<Result, Error> {

        Task<Result, Error> {

            try await transform(try await self.value)
        }
    }

    public func flatMap<Result>(_ transform: @escaping @Sendable (Success) async -> Result) -> Task<Result, Error> where Failure == Error {

        Task<Result, Error> {

            await transform(try await self.value)
        }
    }

    public func flatMap<Result>(_ transform: @escaping @Sendable (Success) async -> Result) -> Task<Result, Never> where Failure == Never {

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
