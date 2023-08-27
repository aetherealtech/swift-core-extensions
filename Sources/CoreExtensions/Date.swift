import Foundation

extension Date : Strideable {
    public typealias Stride = TimeInterval

    public func distance(to other: Date) -> TimeInterval {
        other.timeIntervalSince(self)
    }

    public func advanced(by n: TimeInterval) -> Date {
        addingTimeInterval(n)
    }
}

public extension Strideable {
    static func regularIntervals(
        startingAt start: Self,
        _ interval: Stride,
        until limit: Self
    ) -> StrideTo<Self> {
        stride(
            from: start,
            to: limit,
            by: interval
        )
    }

    static func regularIntervals(
        startingAt start: Self,
        _ interval: Stride,
        count: Int
    ) -> StrideCount<Self> {
        stride(
            from: start,
            by: interval,
            count: count
        )
    }
}

extension Date {
    static func regularIntervals(
        startingAt start: Date = Date(),
        _ interval: TimeInterval,
        until limit: Date = Date.distantFuture
    ) -> StrideTo<Date> {
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
    ) -> StrideCount<Date> {
        stride(
            from: start,
            by: interval,
            count: count
        )
    }
}
