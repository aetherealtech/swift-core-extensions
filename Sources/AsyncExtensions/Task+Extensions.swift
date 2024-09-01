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
public func withTimeout<R: Sendable, C: Clock>(
    after duration: C.Instant.Duration,
    tolerance: C.Instant.Duration? = nil,
    clock: C,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await withTimeout(
        sleep: { try await Task.sleep(for: duration, tolerance: tolerance, clock: clock) },
        work
    )
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public func withTimeout<R: Sendable>(
    after duration: ContinuousClock.Instant.Duration,
    tolerance: ContinuousClock.Instant.Duration? = nil,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await withTimeout(
        after: duration,
        tolerance: tolerance,
        clock: ContinuousClock(),
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

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public func withTimeout<R: Sendable>(
    at instant: ContinuousClock.Instant,
    tolerance: ContinuousClock.Duration? = nil,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await withTimeout(
        at: instant,
        tolerance: tolerance,
        clock: ContinuousClock(),
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
