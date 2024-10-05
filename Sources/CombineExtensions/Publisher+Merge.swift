import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension RandomAccessCollection where Element: Publisher {
    func merge() -> Publishers.MergeCollection<Self> {
        .init(sources: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publishers {
    struct MergeCollection<Sources: RandomAccessCollection>: Publisher where Sources.Element: Publisher {
        public typealias Output = Sources.Element.Output
        public typealias Failure = Sources.Element.Failure
        
        init(
            sources: Sources
        ) {
            self.sources = sources
        }
        
        public func receive(subscriber: some Subscriber<Output, Failure>) {
            let subscription = MergeSubscription(
                upstream: subscriber,
                count: sources.count
            )
            
            subscriber.receive(subscription: subscription)
            
            for (index, source) in sources.enumerated() {
                source.receive(subscriber: subscription.createSubscriber(index: index))
            }
        }
        
        private final class MergeSubscription<Upstream: Subscriber<Output, Failure>>: Subscription {
            init(
                upstream: Upstream,
                count: Int
            ) {
                self.upstream = upstream
   
                _state = .init(wrappedValue: .init(
                    subscriptionStates: .init(repeating: .init(), count: count)
                ))
            }
            
            func request(_ newDemand: Subscribers.Demand) {
                guard newDemand > .none else { return }
                
                var newDemand = newDemand
                
                while true {
                    let (newUpstreamDemand, subscriptions, shouldFinish) = _state.write { state -> (Subscribers.Demand, [any Subscription], Bool) in
                        state.demand += newDemand
                        
                        state.subscriptionStates
                            .mutableForEach { subscriptionState in
                                guard state.demand > 0, let received = subscriptionState.received else {
                                    return
                                }
                                
                                subscriptionState.received = nil
                                state.demand -= 1
                                state.demand += upstream.receive(received)
                            }
                        
                        let newUpstreamDemand: Subscribers.Demand = state.demand == .unlimited ? .unlimited : .max(1)
                        
                        let subscriptions = state.subscriptionStates
                            .mutableCompactMap { subscriptionState -> (any Subscription)? in
                                guard case let .subscribed(subscription, demand) = subscriptionState.mode, subscriptionState.received == nil, demand == .none else {
                                    return nil
                                }
                                
                                subscriptionState.mode = .subscribed(
                                    subscription: subscription,
                                    demand: demand + newUpstreamDemand
                                )
                                
                                return subscription
                            }
                        
                        let shouldFinish = !state.subscriptionStates
                            .lazy
                            .map { subscriptionState in
                                guard case .completed = subscriptionState.mode else {
                                    return false
                                }
                                
                                return subscriptionState.received == nil
                            }
                            .contains(false)
                        
                        return (newUpstreamDemand, subscriptions, shouldFinish)
                    }
                    
                    newDemand = .none
                    
                    if shouldFinish {
                        upstream.receive(completion: .finished)
                        break
                    }
                    
                    if subscriptions.isEmpty {
                        break
                    }
                    
                    subscriptions
                        .forEach { subscription in subscription.request(newUpstreamDemand) }
                }
            }
            
            func cancel() {
                let subscriptions = _state.write { state in
                    state.subscriptionStates
                        .lazy
                        .compactMap {
                            if case let .subscribed(subscription, _) = $0.mode {
                                return subscription
                            }
                            
                            return nil
                        }
                }
                
                for subscription in subscriptions {
                    subscription.cancel()
                }
            }
            
            func createSubscriber(index: Int) -> MergeSubscriber<Upstream> {
                .init(
                    state: _state,
                    upstream: upstream,
                    index: index
                )
            }

            private let upstream: Upstream
            private let _state: Synchronized<State>
        }
        
        private final class MergeSubscriber<Upstream: Subscriber<Output, Failure>>: Subscriber {
            typealias Input = Sources.Element.Output
            typealias Failure = Sources.Element.Failure
            
            init(
                state: Synchronized<State>,
                upstream: Upstream,
                index: Int
            ) {
                _state = state
                self.upstream = upstream
                self.index = index
            }
            
            func receive(subscription: any Subscription) {
                let demand = _state.write { state in
                    let newDemand: Subscribers.Demand = state.demand == .unlimited ? .unlimited : .max(1)
                    
                    state.subscriptionStates.mutate(at: index) { subscriptionState in
                        subscriptionState.mode = .subscribed(
                            subscription: subscription,
                            demand: newDemand
                        )
                    }
                    
                    return newDemand
                }
                
                subscription.request(demand)
            }
            
            func receive(_ input: Sources.Element.Output) -> Subscribers.Demand {
                return _state.write { state in
                    let newDemand: Subscribers.Demand
                    
                    if state.demand > .none {
                        state.demand -= 1
                        let extraDemand = upstream.receive(input)
                        state.demand += extraDemand
                        
                        newDemand = switch extraDemand {
                            case .none: .none
                            case .unlimited: .unlimited
                            default: .max(1)
                        }
                    } else {
                        state.subscriptionStates[index].received = input
                        
                        newDemand = .none
                    }
                    
                    state.subscriptionStates.mutate(at: index) { subscriptionState in
                        if case let .subscribed(subscription, demand) = subscriptionState.mode {
                            subscriptionState.mode = .subscribed(
                                subscription: subscription,
                                demand: demand - 1 + newDemand
                            )
                        }
                    }
                    
                    return newDemand
                }
            }
            
            func receive(completion: Subscribers.Completion<Sources.Element.Failure>) {
                let allFinished = _state.write { state in
                    if case .finished = completion {
                        state.subscriptionStates[index].mode = .completed
                        
                        return !state.subscriptionStates
                            .lazy
                            .map { subscriptionState in
                                guard case .completed = subscriptionState.mode else {
                                    return false
                                }
                                
                                return subscriptionState.received == nil
                            }
                            .contains(false)
                    }
                    
                    return false
                }
                
                switch completion {
                    case let .failure(error):
                        upstream.receive(completion: .failure(error))
                    case .finished:
                        if allFinished {
                            upstream.receive(completion: .finished)
                        }
                }
            }
            
            private let upstream: Upstream
            private let index: Int
            private let _state: Synchronized<State>
        }
        
        private struct State {
            struct SubscriptionState {
                enum Mode {
                    case pending
                    case subscribed(subscription: any Subscription, demand: Subscribers.Demand)
                    case completed
                }
                
                var mode = Mode.pending
                var received: Sources.Element.Output? = nil
            }
            
            var subscriptionStates: [SubscriptionState]
            var demand: Subscribers.Demand = .none
        }
        
        private let sources: Sources
    }
}
