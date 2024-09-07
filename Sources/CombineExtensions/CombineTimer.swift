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
public final class TimerPublisher<S: Scheduler>: Publisher {
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

    public func receive<Sub: Subscriber<Output, Failure>>(subscriber: Sub) {
        subscriber.receive(subscription: TimerSubscription(
            subscriber: subscriber,
            scheduler: scheduler,
            start: start,
            interval: interval
        ))
    }
    
    private struct TimerSubscription<Sub: Subscriber<Void, Never>>: Subscription {
        var combineIdentifier: CombineIdentifier { subscriber.combineIdentifier }
        
        func receive() {
            _state.write { state in
                state.demand -= 1
                state.demand += subscriber.receive(())
                
                if state.demand == .none {
                    state.subscription?.cancel()
                    state.subscription = nil
                }
            }
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else {
                return
            }
            
            _state.write { state in
                state.demand += demand
                
                if state.subscription == nil {
                    state.subscription = scheduler.schedule(
                        after: start,
                        interval: interval,
                        receive
                    )
                }
            }
        }
        
        func cancel() {
            _state.write { state in
                state.demand = .none
                state.subscription?.cancel()
                state.subscription = nil
            }
        }

        let subscriber: Sub
        let scheduler: S
        let start: S.SchedulerTimeType
        let interval: S.SchedulerTimeType.Stride

        private struct State {
            var subscription: (any Cancellable)?
            var demand: Subscribers.Demand = .none
        }
        
        @Synchronized
        private var state: State = .init()
    }

    private let scheduler: S
    private let start: S.SchedulerTimeType
    private let interval: S.SchedulerTimeType.Stride
}
