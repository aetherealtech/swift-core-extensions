import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Scheduler {
    func timer(
        start: SchedulerTimeType,
        interval: SchedulerTimeType.Stride
    ) -> TimerPublisher<Self> {
        TimerPublisher(
            scheduler: self,
            start: start,
            interval: interval
        )
    }
    
    func timer(
        interval: SchedulerTimeType.Stride
    ) -> TimerPublisher<Self> {
        timer(
            start: self.now,
            interval: interval
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private protocol TimerSubscriber {
    func receive()
    
    func appending<Sub: Subscriber<Void, Never>>(subscriber: SingleTimerSubscriber<Sub>) -> any TimerSubscriber
    func removing<Sub: Subscriber<Void, Never>>(subscriber: SingleTimerSubscriber<Sub>) -> (any TimerSubscriber)?
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct SingleTimerSubscriber<Sub: Subscriber<Void, Never>>: TimerSubscriber, Subscription {
    var combineIdentifier: CombineIdentifier { subscriber.combineIdentifier }
    
    func receive() {
        _demand.write { demand in
            guard demand > 0 else {
                return
            }

            demand -= 1
            demand += subscriber.receive(())
        }
    }
    
    func request(_ demand: Subscribers.Demand) {
        self.demand += demand
    }
    
    func cancel() {
        cancelImp(self)
    }
    
    func appending<Other: Subscriber<Void, Never>>(subscriber: SingleTimerSubscriber<Other>) -> any TimerSubscriber {
        PairTimerSubscriber(first: self, second: subscriber)
    }
    
    func removing<Other: Subscriber<Void, Never>>(subscriber: SingleTimerSubscriber<Other>) -> (any TimerSubscriber)? {
        if subscriber.subscriber.combineIdentifier == self.subscriber.combineIdentifier {
            return nil
        } else {
            return self
        }
    }

    let subscriber: Sub
    let cancelImp: (Self) -> Void

    @Synchronized
    private var demand: Subscribers.Demand = .none
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct PairTimerSubscriber<Sub: Subscriber<Void, Never>, Next: TimerSubscriber>: TimerSubscriber {
    func receive() {
        first.receive()
        second.receive()
    }
    
    func appending<Other: Subscriber<Void, Never>>(subscriber: SingleTimerSubscriber<Other>) -> any TimerSubscriber {
        return second.appending(subscriber: subscriber).append(to: first)
    }
    
    func removing<Other: Subscriber<Void, Never>>(subscriber: SingleTimerSubscriber<Other>) -> (any TimerSubscriber)? {
        if subscriber.subscriber.combineIdentifier == first.subscriber.combineIdentifier {
            return second
        } else {
            if let next = second.removing(subscriber: subscriber) {
                return next.append(to: first)
            } else {
                return first
            }
        }
    }

    let first: SingleTimerSubscriber<Sub>
    let second: Next
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private extension TimerSubscriber {
    func append<Sub: Subscriber<Void, Never>>(to first: SingleTimerSubscriber<Sub>) -> any TimerSubscriber {
        PairTimerSubscriber(first: first, second: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension (any TimerSubscriber)? {
    mutating fileprivate func append<Sub: Subscriber<Void, Never>>(_ subscriber: SingleTimerSubscriber<Sub>) {
        self = self?.appending(subscriber: subscriber) ?? subscriber
    }
    
    mutating fileprivate func remove<Sub: Subscriber<Void, Never>>(_ subscriber: SingleTimerSubscriber<Sub>) {
        self = self?.removing(subscriber: subscriber)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class TimerPublisher<S: Scheduler>: ConnectablePublisher {
    public typealias Output = Void
    public typealias Failure = Never

    init(
        scheduler: S,
        start: S.SchedulerTimeType,
        interval: S.SchedulerTimeType.Stride
    ) {
        self.scheduler = scheduler
        self.start = start
        self.interval = interval
    }

    public func connect() -> Cancellable {
        scheduler.schedule(
            after: start,
            interval: interval,
            fire
        )
    }

    public func receive<Sub: Subscriber<Output, Failure>>(subscriber: Sub) {
        let subscription = SingleTimerSubscriber(
            subscriber: subscriber
        ) { [_subscriptions] subscription in
            _subscriptions.write { subscriptions in subscriptions.remove(subscription) }
        }
        
        _subscriptions.write { subscriptions in subscriptions.append(subscription) }

        subscriber.receive(subscription: subscription)
    }

    private let scheduler: S
    private let start: S.SchedulerTimeType
    private let interval: S.SchedulerTimeType.Stride

    @Synchronized
    private var subscriptions: (any TimerSubscriber)?

    private func fire() {
        subscriptions?.receive()
    }
}
