import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension TimeInterval: SchedulerTimeIntervalConvertible {
    public static func seconds(_ s: Int) -> TimeInterval {
        TimeInterval(s)
    }

    public static func seconds(_ s: Double) -> TimeInterval {
        s
    }

    public static func milliseconds(_ ms: Int) -> TimeInterval {
        TimeInterval(ms) / 1e3
    }

    public static func microseconds(_ us: Int) -> TimeInterval {
        TimeInterval(us) / 1e6
    }

    public static func nanoseconds(_ ns: Int) -> TimeInterval {
        TimeInterval(ns) / 1e9
    }
    
    func stride<I: Comparable & Numeric & SchedulerTimeIntervalConvertible>() -> I {
        I.nanoseconds(Int(self * 1e9))
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnyScheduler: Scheduler {
    public struct AnyTime: Strideable {
        public func distance(to other: AnyTime) -> TimeInterval {
            other.date.timeIntervalSince(date)
        }
        
        public func advanced(by n: TimeInterval) -> AnyTime {
            .init(date: date.addingTimeInterval(n))
        }
        
        func schedulerTime<S: Scheduler>(scheduler: S) -> S.SchedulerTimeType {
            scheduler.now.advanced(by: date.timeIntervalSinceNow.stride())
        }
        
        let date: Date
    }
    
    public typealias SchedulerTimeType = AnyTime
    public typealias SchedulerOptions = Void

    init<S: Scheduler>(
        erasing: S
    ) {
        erased = erasing
        
        scheduleImp = { erased, action in
            (erased as! S).schedule(options: nil, action)
        }

        scheduleAfterImp = { erased, date, tolerance, action in
            let scheduler = erased as! S
            scheduler.schedule(
                after: date.schedulerTime(scheduler: scheduler),
                tolerance: tolerance.stride(),
                options: nil,
                action
            )
        }

        scheduleRepeatingImp = { erased, date, interval, tolerance, action in
            let scheduler = erased as! S
            return scheduler.schedule(
                after: date.schedulerTime(scheduler: scheduler),
                interval: interval.stride(),
                tolerance: tolerance.stride(),
                options: nil,
                action
            )
        }
    }
    
    init(
        erasing: AnyScheduler
    ) {
        erased = erasing.erased
        scheduleImp = erasing.scheduleImp
        scheduleAfterImp = erasing.scheduleAfterImp
        scheduleRepeatingImp = erasing.scheduleRepeatingImp
    }

    public var now: SchedulerTimeType { .init(date: Date()) }
    public var minimumTolerance: SchedulerTimeType.Stride { 1e-9 }

    public func schedule(options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        scheduleImp(erased, action)
    }

    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        scheduleAfterImp(erased, date, tolerance, action)
    }

    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options _: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        scheduleRepeatingImp(erased, date, interval, tolerance, action)
    }

    private var erased: Any
    
    private let scheduleImp: (Any, _ action: @escaping () -> Void) -> Void
    private let scheduleAfterImp: (Any, _ date: AnyTime, _ tolerance: TimeInterval, _ action: @escaping () -> Void) -> Void
    private let scheduleRepeatingImp: (Any, _ date: AnyTime, _ interval: TimeInterval, _ tolerance: TimeInterval, _ action: @escaping () -> Void) -> Cancellable
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler {
        AnyScheduler(erasing: self)
    }
}
