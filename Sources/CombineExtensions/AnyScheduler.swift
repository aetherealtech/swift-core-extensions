import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnyScheduler: Scheduler {
    public struct AnyTime: Strideable {
        public struct Stride: Comparable, SignedNumeric, SchedulerTimeIntervalConvertible {
            public static func seconds(_ s: Int) -> Self {
                .init(nanoseconds: Int64(s) * 1_000_000_000)
            }

            public static func seconds(_ s: Double) -> Self {
                .init(nanoseconds: Int64(s * 1e9))
            }

            public static func milliseconds(_ ms: Int) -> Self {
                .init(nanoseconds: Int64(ms) * 1_000_000)
            }

            public static func microseconds(_ us: Int) -> Self {
                .init(nanoseconds: Int64(us) * 1_000)
            }

            public static func nanoseconds(_ ns: Int) -> Self {
                .init(nanoseconds: Int64(ns))
            }
            
            public static func < (lhs: Self, rhs: Self) -> Bool {
                lhs.nanoseconds < rhs.nanoseconds
            }
                        
            public init(integerLiteral value: Int64) {
                nanoseconds = value
            }
            
            public init?(exactly source: some BinaryInteger) {
                guard let seconds = Int(exactly: source) else {
                    return nil
                    
                }
                
                self = .seconds(seconds)
            }
            
            public static func + (lhs: Self, rhs: Self) -> Self {
                .init(nanoseconds: lhs.nanoseconds + rhs.nanoseconds)
            }
            
            public static func - (lhs: Self, rhs: Self) -> Self {
                .init(nanoseconds: lhs.nanoseconds - rhs.nanoseconds)
            }
            
            public static func * (lhs: Self, rhs: Self) -> Self {
                .init(nanoseconds: lhs.nanoseconds * rhs.nanoseconds)
            }
            
            public static func *= (lhs: inout Self, rhs: Self) {
                lhs.nanoseconds *= rhs.nanoseconds
            }
            
            public var magnitude: UInt64 { nanoseconds.magnitude }
            
            func stride<I: Comparable & Numeric & SchedulerTimeIntervalConvertible>() -> I {
                I.nanoseconds(Int(nanoseconds))
            }
            
            init(nanoseconds: Int64) {
                self.nanoseconds = nanoseconds
            }
            
            private(set) var nanoseconds: Int64
        }
        
        public static var now: Self {
            .init(nanoseconds: DispatchTime.now().uptimeNanoseconds)
        }
        
        public func distance(to other: AnyTime) -> Stride {
            .init(nanoseconds: .init(other.nanoseconds) - .init(nanoseconds))
        }
        
        public func advanced(by n: Stride) -> AnyTime {
            .init(nanoseconds: nanoseconds + .init(n.nanoseconds))
        }
        
        func schedulerTime<S: Scheduler>(scheduler: S) -> S.SchedulerTimeType {
            scheduler.now.advanced(by: AnyTime.now.distance(to: self).stride())
        }
        
        private let nanoseconds: UInt64
    }
    
    public typealias SchedulerTimeType = AnyTime
    public typealias SchedulerOptions = Void

    init<S: Scheduler>(
        erasing: S
    ) {
        if let erased = erasing as? AnyScheduler {
            unwrap = erased.unwrap
            scheduleAfterImp = erased.scheduleAfterImp
            scheduleRepeatingImp = erased.scheduleRepeatingImp
        } else {
            unwrap = erasing
   
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
    }

    public var now: SchedulerTimeType { .now }
    public var minimumTolerance: SchedulerTimeType.Stride { .init(nanoseconds: 1) }

    public func schedule(options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        unwrap.schedule(action)
    }

    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options _: SchedulerOptions?, _ action: @escaping () -> Void) {
        scheduleAfterImp(unwrap, date, tolerance, action)
    }

    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options _: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        scheduleRepeatingImp(unwrap, date, interval, tolerance, action)
    }

    public let unwrap: any Scheduler
    
    private let scheduleAfterImp: (Any, _ date: SchedulerTimeType, _ tolerance: SchedulerTimeType.Stride, _ action: @escaping () -> Void) -> Void
    private let scheduleRepeatingImp: (Any, _ date: SchedulerTimeType, _ interval: SchedulerTimeType.Stride, _ tolerance: SchedulerTimeType.Stride, _ action: @escaping () -> Void) -> Cancellable
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler {
        AnyScheduler(erasing: self)
    }
}
