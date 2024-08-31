import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task: Cancellable {}

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
extension Task where Failure == Error {
    public func waitUntilDone() async throws {
        _ = try await value
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task where Failure == Never {
    public func waitUntilDone() async {
        _ = await value
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task {
    public func map<Result>(_ transform: @escaping @Sendable (Success) throws -> Result) -> Task<Result, Error> {
        .init {
            try transform(try await self.value)
        }
    }

    public func map<Result>(_ transform: @escaping @Sendable (Success) -> Result) -> Task<Result, Error> where Failure == Error {
        .init {
            transform(try await self.value)
        }
    }

    public func map<Result>(_ transform: @escaping @Sendable (Success) -> Result) -> Task<Result, Never> where Failure == Never {
        .init {
            transform(await self.value)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task {
    public func flatten<InnerSuccess, InnerFailure: Error>() -> Task<InnerSuccess, Error> where Success == Task<InnerSuccess, InnerFailure> {
        .init {
            try await value.value
        }
    }
    
    public func flatten<InnerSuccess>() -> Task<InnerSuccess, Never> where Success == Task<InnerSuccess, Never>, Failure == Never {
        .init {
            await value.value
        }
    }
    
    public func flatMap<Result, ResultFailure: Error>(_ transform: @escaping @Sendable (Success) -> Task<Result, ResultFailure>) -> Task<Result, Error> {
        map(transform)
            .flatten()
    }
    
    public func flatMap<Result>(_ transform: @escaping @Sendable (Success) -> Task<Result, Never>) -> Task<Result, Never> where Failure == Never {
        map(transform)
            .flatten()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task {
    func combineThrowing<each Successes, each Failures>(
        _ tasks: repeat Task<each Successes, each Failures>
    ) -> Task<(Success, repeat each Successes), Error> {
        Task<Void, Never>.combineThrowing(
            self,
            repeat each tasks
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task where Failure == Never {
    func combine<each Successes>(
        _ tasks: repeat Task<each Successes, Never>
    ) -> Task<(Success, repeat each Successes), Never> {
        Task<Void, Never>.combine(
            self,
            repeat each tasks
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task where Success == Void {
    func combineThrowing<each Failures>(
        _ tasks: repeat Task<Void, each Failures>
    ) -> Task<Void, Error> {
        Task<Void, Never>.combineThrowing(
            self,
            repeat each tasks
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Task where Success == Void, Failure == Never {
    func combine(
        _ tasks: Task<Void, Never>...
    ) -> Task<Void, Never> {
        Task<Void, Never>.combine(
            [[self], tasks].flatMap { $0 }
        )
    }
    
    func combine(
        _ tasks: some Sequence<Task<Void, Never>> & Sendable
    ) -> Task<Void, Never> {
        Task<Void, Never>.combine(
            [[self], Array(tasks)].flatMap { $0 }
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Task where Success == Void, Failure == Never {
    static func combineThrowing<each Successes, each Failures>(
        _ tasks: repeat Task<each Successes, each Failures>
    ) -> Task<(repeat each Successes), Error> {
        .init {
            (repeat try await (each tasks).value)
        }
    }
    
    static func combineThrowing<each Failures>(
        _ tasks: repeat Task<Void, each Failures>
    ) -> Task<Void, Error> {
        .init {
            (repeat try await (each tasks).value)
        }
    }
    
    static func combine<each Successes>(
        _ tasks: repeat Task<each Successes, Never>
    ) -> Task<(repeat each Successes), Never> {
        .init {
            (repeat await (each tasks).value)
        }
    }
    
    static func combine(
        _ tasks: Task<Void, Never>...
    ) -> Task<Void, Never> {
        combine(tasks)
    }
    
    static func combine(
        _ tasks: some Sequence<Task<Void, Never>> & Sendable
    ) -> Task<Void, Never> {
        .init {
            for task in tasks { await task.value }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func combine<Success>() -> Task<[Success], Error> where Element == Task<Success, Error> {
        .init {
            var results = [Success]()
            
            for task in self {
                results.append(try await task.value)
            }
            
            return results
        }
    }
    
    func combine<Success>() -> Task<[Success], Never> where Element == Task<Success, Never> {
        .init {
            var results = [Success]()
            
            for task in self {
                results.append(await task.value)
            }
            
            return results
        }
    }
}
