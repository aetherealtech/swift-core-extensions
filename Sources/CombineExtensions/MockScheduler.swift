import Combine
import DateExtensions
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class MockCancellable: Cancellable {
    public init() {}

    public var cancelInvocations: [Void] = .init()
    public func cancel() {
        cancelInvocations.append(())
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class MockScheduler: Scheduler {
    public typealias SchedulerTimeType = AnyScheduler.SchedulerTimeType
    public typealias SchedulerOptions = Void

    public init() {}

    public var now: SchedulerTimeType { .now }
    public var minimumTolerance: SchedulerTimeType.Stride { .init(nanoseconds: 1) }

    public func schedule(options _: SchedulerOptions?, _: @escaping () -> Void) {}

    public func schedule(after _: SchedulerTimeType, tolerance _: SchedulerTimeType.Stride, options _: SchedulerOptions?, _: @escaping () -> Void) {}

    public typealias ScheduleRepeatingInvocation = (date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, action: () -> Void)
    public var scheduleRepeatingInvocations = [ScheduleRepeatingInvocation]()
    public var scheduleRepeatingSetup: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Cancellable = { _, _, _, _, _ in MockCancellable() }
    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        scheduleRepeatingInvocations.append((date, interval, tolerance, options, action))
        return scheduleRepeatingSetup(date, interval, tolerance, options, action)
    }
}
