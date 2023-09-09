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
