import CollectionExtensions
import Foundation

@available(macOS, obsoleted: 13.0, message: "Date itself is not Strideable")
@available(iOS, obsoleted: 16.0, message: "Date itself is not Strideable")
@available(tvOS, obsoleted: 16.0, message: "Date itself is not Strideable")
@available(watchOS, obsoleted: 9.0, message: "Date itself is not Strideable")
public struct StrideableDate: Strideable {
    public typealias Stride = TimeInterval

    public func distance(to other: Self) -> TimeInterval {
        other.date.timeIntervalSince(date)
    }

    public func advanced(by n: TimeInterval) -> Self {
        .init(date: date.addingTimeInterval(n))
    }
    
    public let date: Date
}

public struct DateStrideTo: Sequence {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Date? {
            iterator.next()?.date
        }
        
        var iterator: StrideTo<StrideableDate>.Iterator
    }
    
    public func makeIterator() -> Iterator {
        .init(iterator: strideTo.makeIterator())
    }
    
    let strideTo: StrideTo<StrideableDate>
}

public struct DateStrideCount: Sequence {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Date? {
            iterator.next()?.date
        }
        
        var iterator: StrideCount<StrideableDate>.Iterator
    }
    
    public func makeIterator() -> Iterator {
        .init(iterator: strideTo.makeIterator())
    }
    
    let strideTo: StrideCount<StrideableDate>
}

public extension Date {
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
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

    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
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
    
    @available(macOS, obsoleted: 13.0, message: "Date itself is not Strideable")
    @available(iOS, obsoleted: 16.0, message: "Date itself is not Strideable")
    @available(tvOS, obsoleted: 16.0, message: "Date itself is not Strideable")
    @available(watchOS, obsoleted: 9.0, message: "Date itself is not Strideable")
    static func regularIntervals(
        startingAt start: Date = Date(),
        _ interval: TimeInterval,
        until limit: Date = Date.distantFuture
    ) -> DateStrideTo {
        .init(strideTo: stride(
            from: StrideableDate(date: start),
            to: StrideableDate(date: limit),
            by: interval
        ))
    }

    @available(macOS, obsoleted: 13.0, message: "Date itself is not Strideable")
    @available(iOS, obsoleted: 16.0, message: "Date itself is not Strideable")
    @available(tvOS, obsoleted: 16.0, message: "Date itself is not Strideable")
    @available(watchOS, obsoleted: 9.0, message: "Date itself is not Strideable")
    static func regularIntervals(
        startingAt start: Date = Date(),
        _ interval: TimeInterval,
        count: Int
    ) -> DateStrideCount {
        .init(strideTo: stride(
            from: StrideableDate(date: start),
            by: interval,
            count: count
        ))
    }
}
