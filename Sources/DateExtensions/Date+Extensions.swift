import CollectionExtensions
import Foundation

private extension Date {
    @inline(__always)
    func distance_backport(to other: Date) -> TimeInterval {
        other.timeIntervalSince(self)
    }

    @inline(__always)
    func advanced_backport(by n: TimeInterval) -> Date {
        addingTimeInterval(n)
    }
}

#if DEBUG
nonisolated(unsafe) var __forceBackport = false
#else
let __forceBackport = false
#endif

@available(macOS, obsoleted: 13.0, message: "Date itself is now Strideable")
@available(iOS, obsoleted: 16.0, message: "Date itself is now Strideable")
@available(tvOS, obsoleted: 16.0, message: "Date itself is now Strideable")
@available(watchOS, obsoleted: 9.0, message: "Date itself is now Strideable")
public struct StrideableDate: Strideable {
    public typealias Stride = TimeInterval

    public func distance(to other: Self) -> TimeInterval {
        if #available(macOS 10.15, iOS 16.0, tvOS 16.0, watchOS 9.0, *), !__forceBackport {
            return date.distance(to: other.date)
        } else {
            return date.distance_backport(to: other.date)
        }
    }

    public func advanced(by n: TimeInterval) -> Self {
        if #available(macOS 10.15, iOS 16.0, tvOS 16.0, watchOS 9.0, *), !__forceBackport {
            return .init(date: date.advanced(by: n))
        } else {
            return .init(date: date.advanced_backport(by: n))
        }
    }
    
    public let date: Date
}

@available(macOS, obsoleted: 13.0, message: "Date itself is now Strideable")
@available(iOS, obsoleted: 16.0, message: "Date itself is now Strideable")
@available(tvOS, obsoleted: 16.0, message: "Date itself is now Strideable")
@available(watchOS, obsoleted: 9.0, message: "Date itself is now Strideable")
public func stride(
    from start: Date,
    to end: Date,
    by interval: TimeInterval
) -> LazyMapSequence<LazySequence<StrideTo<StrideableDate>>.Elements, Date> {
    stride(
        from: .init(date: start),
        to: .init(date: end),
        by: interval
    )
    .lazy
    .map(\.date)
}

@available(macOS, obsoleted: 13.0, message: "Date itself is now Strideable")
@available(iOS, obsoleted: 16.0, message: "Date itself is now Strideable")
@available(tvOS, obsoleted: 16.0, message: "Date itself is now Strideable")
@available(watchOS, obsoleted: 9.0, message: "Date itself is now Strideable")
public func stride(
    from start: Date,
    by interval: TimeInterval,
    count: Int
) -> LazyMapSequence<LazySequence<StrideCount<StrideableDate>>.Elements, Date> {
    stride(
        from: .init(date: start),
        by: interval,
        count: count
    )
    .lazy
    .map(\.date)
}

public extension Date {
    static func regularIntervals(
        startingAt start: Date = Date(),
        _ interval: TimeInterval,
        until limit: Date = Date.distantFuture
    ) -> LazyMapSequence<LazySequence<StrideTo<StrideableDate>>.Elements, Date> {
        stride(
            from: start,
            to: limit,
            by: interval
        )
    }

    static func regularIntervals(
        startingAt start: Date = Date(),
        _ interval: TimeInterval,
        count: Int
    ) -> LazyMapSequence<LazySequence<StrideCount<StrideableDate>>.Elements, Date> {
        stride(
            from: start,
            by: interval,
            count: count
        )
    }
}
