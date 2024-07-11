import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Element: Publisher {
    func merge() -> some Publisher<Element.Output, Element.Failure> {
        MergePublisher(sources: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct MergePublisher<Sources: Sequence>: Publisher where Sources.Element: Publisher {
    typealias Output = Sources.Element.Output
    typealias Failure = Sources.Element.Failure

    init(
        sources: Sources
    ) {
        self.sources = sources
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        subscriber.receive(subscription: MergeSubscription(
            sources: sources,
            subscriber: subscriber
        ))
    }

    private final class MergeSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        init(
            sources: Sources,
            subscriber: S
        ) {
            state = .init(
                subscriber: subscriber
            )

            sources.forEach { source in
                source.receive(subscriber: MergeSubscriber(
                    state: _state
                ))
            }
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else { return }
            
            let requestUpstream = _state.write { state -> () -> Void in
                state.demand += demand
                let pendingValues = state.pendingValues.dropFirst(state.demand.max ?? .max)
                state.demand -= pendingValues.count
                
                for pendingValue in pendingValues {
                    state.demand += state.subscriber.receive(pendingValue)
                }
             
                return { [demand = state.demand, subscriptions = state.subscriptions.values] in
                    if demand > .none {
                        let upstreamDemand = demand == .unlimited ? Subscribers.Demand.unlimited : .max(1)
                        subscriptions.forEach { subscription in subscription.request(upstreamDemand) }
                    }
                }
            }
            
            requestUpstream()
        }

        func cancel() {
            _state.write { state in
                state.subscriptions.values.forEach { subscription in subscription.cancel() }
            }
        }

        private struct State {
            var subscriber: S
            var subscriptions: [CombineIdentifier: Subscription] = [:]
            var demand: Subscribers.Demand = .none
            var pendingValues: [Sources.Element.Output] = []
        }

        private final class MergeSubscriber: Subscriber {
            typealias Input = Sources.Element.Output
            typealias Failure = Sources.Element.Failure

            init(
                state: Synchronized<State>
            ) {
                _state = state
            }

            func receive(subscription: Subscription) {
                subscriptionId = subscription.combineIdentifier
                _state.subscriptions[subscription.combineIdentifier] = subscription
            }

            func receive(_ input: Sources.Element.Output) -> Subscribers.Demand {
                _state.write { state in
                    if state.demand > .none {
                        state.demand -= 1
                        state.demand += state.subscriber.receive(input)
                    } else {
                        state.pendingValues.append(input)
                    }
                    
                    return state.demand > .none ? .max(1) : .none
                }
            }

            func receive(completion: Subscribers.Completion<Sources.Element.Failure>) {
                _state.write { state in
                    switch completion {
                        case let .failure(error):
                            state.subscriber.receive(completion: .failure(error))
                        case .finished:
                            if let subscriptionId {
                                state.subscriptions[subscriptionId] = nil
                            }
                            
                            if state.subscriptions.isEmpty {
                                state.subscriber.receive(completion: .finished)
                            }
                    }
                }
            }

            private var subscriptionId: CombineIdentifier?
            
            @Synchronized 
            private var state: State
        }

        @Synchronized 
        private var state: State
    }

    private let sources: Sources
}
