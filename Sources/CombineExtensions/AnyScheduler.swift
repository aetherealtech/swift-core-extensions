import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Date: Strideable {}

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
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnyScheduler: Scheduler {
    public typealias SchedulerTimeType = Date
    public typealias SchedulerOptions = Void

    init<S: Scheduler>(
        erasing: S
    ) {
        let convertTimeStride: (TimeInterval) -> S.SchedulerTimeType.Stride = { interval in S.SchedulerTimeType.Stride.nanoseconds(Int(interval * 1e9)) }
        let convertTimeType: (Date) -> S.SchedulerTimeType = { date in erasing.now.advanced(by: convertTimeStride(date.timeIntervalSinceNow)) }

        erased = erasing
        
        scheduleImp = { erased, action in
            (erased as! S).schedule(options: nil, action)
        }

        scheduleAfterImp = { erased, date, tolerance, action in
            (erased as! S).schedule(
                after: convertTimeType(date),
                tolerance: convertTimeStride(tolerance),
                options: nil,
                action
            )
        }

        scheduleRepeatingImp = { erased, date, interval, tolerance, action in
            (erased as! S).schedule(
                after: convertTimeType(date),
                interval: convertTimeStride(interval),
                tolerance: convertTimeStride(tolerance),
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

    public var now: SchedulerTimeType { Date() }
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
    private let scheduleAfterImp: (Any, _ date: Date, _ tolerance: TimeInterval, _ action: @escaping () -> Void) -> Void
    private let scheduleRepeatingImp: (Any, _ date: Date, _ interval: TimeInterval, _ tolerance: TimeInterval, _ action: @escaping () -> Void) -> Cancellable
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler {
        AnyScheduler(erasing: self)
    }
}
