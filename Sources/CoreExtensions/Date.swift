//
//  Created by Daniel Coleman on 1/12/22.
//

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

extension Date {

    static func regularIntervals(
        startingAt start: Date = Date(),
        _ interval: TimeInterval,
        until limit: Date = Date.distantFuture
    ) -> StrideTo<Date> {

        stride(from: start, to: limit, by: interval)
    }

    static func regularIntervals(
        startingAt start: Date = Date(),
        _ interval: TimeInterval,
        count: Int
    ) -> StrideCount<Date> {

        stride(from: start, by: interval, count: count)
    }
}