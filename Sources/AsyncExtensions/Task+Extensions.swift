import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Task where Success == Never, Failure == Never {
    /// Convenience sleep function in terms of *TimeInterval* (seconds)
    static func sleep(timeInterval: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(timeInterval * 1e9))
    }
}

public struct TimedOut: Error {}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public func withTimeout<R: Sendable>(
    after duration: Duration,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await [
        work,
        {
            try await Task.sleep(for: duration)
            throw TimedOut()
        }
    ].awaitAny()!
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func withTimeout<R: Sendable>(
    timeInterval timeout: TimeInterval,
    @_inheritActorContext @_implicitSelfCapture _ work: __owned @Sendable @escaping () async throws -> R
) async throws -> R {
    try await [
        work,
        {
            try await Task.sleep(timeInterval: timeout)
            throw TimedOut()
        }
    ].awaitAny()!
}
