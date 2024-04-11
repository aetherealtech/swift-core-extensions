import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Scheduler {
    func timer(
        start: SchedulerTimeType,
        interval: SchedulerTimeType.Stride
    ) -> some Publisher<Void, Never> {
        TimerPublisher(
            scheduler: self,
            start: start,
            interval: interval
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private protocol BaseTimerSubscription: Subscription {
    func receive()
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TimerPublisher<S: Scheduler>: ConnectablePublisher {
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

    public func receive<Sub>(subscriber: Sub) where Sub: Subscriber, Failure == Sub.Failure, Output == Sub.Input {
        let subscription = TimerSubscription(
            subscriber: subscriber,
            cancel: { subscription in self._subscriptions.write { subscriptions in subscriptions.removeAll(where: { sub in sub.combineIdentifier == subscription.combineIdentifier }) } }
        )

        _subscriptions.write { subscriptions in subscriptions.append(subscription) }

        subscriber.receive(subscription: subscription)
    }

    private final class TimerSubscription<Sub: Subscriber>: BaseTimerSubscription where Sub.Input == Void, Sub.Failure == Never {
        init(
            subscriber: Sub,
            cancel: @escaping (BaseTimerSubscription) -> Void
        ) {
            self.subscriber = subscriber
            cancelImp = cancel
        }

        func request(_ demand: Subscribers.Demand) {
            self.demand += demand
        }

        func cancel() {
            cancelImp(self)
        }

        func receive() {
            _demand.write { demand in
                guard demand > 0 else {
                    return
                }

                demand -= 1
                demand += subscriber.receive(())
            }
        }

        private let subscriber: Sub
        private let cancelImp: (BaseTimerSubscription) -> Void

        @Synchronized private var demand: Subscribers.Demand = .none
    }

    private let scheduler: S
    private let start: S.SchedulerTimeType
    private let interval: S.SchedulerTimeType.Stride

    @Synchronized
    private var subscriptions: [BaseTimerSubscription] = []

    private func fire() {
        for subscription in subscriptions {
            subscription.receive()
        }
    }
}
