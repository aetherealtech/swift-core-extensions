import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Scheduler {
    func timer(
        start: SchedulerTimeType,
        interval: SchedulerTimeType.Stride
    ) -> Publishers.Timer<Self> {
        .init(
            scheduler: self,
            start: start,
            interval: interval
        )
    }
    
    func timer(
        interval: SchedulerTimeType.Stride
    ) -> Publishers.Timer<Self> {
        timer(
            start: self.now,
            interval: interval
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publishers {
    struct Timer<S: Scheduler>: Publisher {
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
        
        public func receive(subscriber: some Subscriber<Output, Failure>) {
            subscriber.receive(subscription: TimerSubscription(
                subscriber: subscriber,
                scheduler: scheduler,
                start: start,
                interval: interval
            ))
        }
        
        private struct TimerSubscription<Sub: Subscriber<Output, Failure>>: Subscription {
            let combineIdentifier = CombineIdentifier()
            
            func receive() {
                _state.write { state in
                    if state.demand > .none {
                        state.demand -= 1
                        state.demand += subscriber.receive(())
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
            
            // Explicit initializer adds test coverage to the lines that initialize members in-line
            init(
                subscriber: Sub,
                scheduler: S,
                start: S.SchedulerTimeType,
                interval: S.SchedulerTimeType.Stride
            ) {
                self.subscriber = subscriber
                self.scheduler = scheduler
                self.start = start
                self.interval = interval
            }
            
            let subscriber: Sub
            let scheduler: S
            let start: S.SchedulerTimeType
            let interval: S.SchedulerTimeType.Stride
            
            private struct State {
                var subscription: (any Cancellable)?
                var demand: Subscribers.Demand = .none
            }
            
            private let _state = Synchronized<State>(wrappedValue: .init())
        }
        
        public let scheduler: S
        public let start: S.SchedulerTimeType
        public let interval: S.SchedulerTimeType.Stride
    }
}
