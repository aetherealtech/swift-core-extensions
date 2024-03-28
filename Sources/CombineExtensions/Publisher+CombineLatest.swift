import CollectionExtensions
import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Collection where Element: Publisher {
    func combineLatest() -> CombineLatestPublisher<Self> {
        CombineLatestPublisher<Self>(sources: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct CombineLatestPublisher<Sources: Collection>: Publisher where Sources.Element: Publisher {
    public typealias Output = [Sources.Element.Output]
    public typealias Failure = Sources.Element.Failure

    init(
        sources: Sources
    ) {
        self.sources = sources
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        subscriber.receive(subscription: CombineLatestSubscription(
            sources: sources,
            subscriber: subscriber
        ))
    }

    private final class CombineLatestSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        init(
            sources: Sources,
            subscriber: S
        ) {
            state = .init(
                subscriber: subscriber,
                subscriptions: .init(repeating: nil, count: sources.count),
                currentValues: .init(repeating: nil, count: sources.count)
            )

            sources.enumerated().forEach { index, source in
                source.receive(subscriber: CombineLatestSubscriber(
                    index: index,
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
             
                return { [demand = state.demand, subscriptions = state.subscriptions.compact()] in
                    if demand > .none {
                        let upstreamDemand: Subscribers.Demand = demand == .unlimited ? .unlimited : .max(1)
                        subscriptions.forEach { subscription in subscription.request(upstreamDemand) }
                    }
                }
            }
            
            requestUpstream()
        }

        func cancel() {
            _state.write { state in
                state.subscriptions.forEach { subscription in subscription?.cancel() }
            }
        }

        private func makeSubscriber(index: Int) -> CombineLatestSubscriber {
            .init(
                index: index,
                state: _state
            )
        }

        private struct State {
            var subscriber: S
            var subscriptions: [Subscription?]
            var demand: Subscribers.Demand = .none
            var currentValues: [Sources.Element.Output?]
            var pendingValues: [[Sources.Element.Output]] = []
        }

        private final class CombineLatestSubscriber: Subscriber {
            typealias Input = Sources.Element.Output
            typealias Failure = Sources.Element.Failure

            init(
                index: Int,
                state: Synchronized<State>
            ) {
                self.index = index

                _state = state
            }

            func receive(subscription: Subscription) {
                _state.subscriptions[index] = subscription
            }

            func receive(_ input: Sources.Element.Output) -> Subscribers.Demand {
                _state.write { state -> Subscribers.Demand in
                    state.currentValues[index] = input

                    let readyValues = state.currentValues.compact()

                    if readyValues.count == state.currentValues.count {
                        if state.demand > .none {
                            state.demand -= 1
                            state.demand += state.subscriber.receive(readyValues)
                        } else {
                            state.pendingValues.append(readyValues)
                        }
                        
                        return state.demand > .none ? .max(1) : .none
                    }
                    
                    return .max(1)
                }
            }

            func receive(completion: Subscribers.Completion<Sources.Element.Failure>) {
                _state.write { state in
                    switch completion {
                        case let .failure(error):
                            state.subscriber.receive(completion: .failure(error))
                        case .finished:
                            state.subscriptions[index] = nil
                            
                            if state.currentValues[index] == nil || state.subscriptions.compact().isEmpty {
                                state.subscriber.receive(completion: .finished)
                            }
                    }
                }
            }

            private let index: Int

            @Synchronized
            private var state: State
        }

        @Synchronized
        private var state: State
    }

    private let sources: Sources
}
