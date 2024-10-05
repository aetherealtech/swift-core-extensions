import CollectionExtensions
import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension RandomAccessCollection where Element: Publisher {
    func combineLatest() -> Publishers.CombineLatestCollection<Self> {
        .init(sources: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publishers {
    struct CombineLatestCollection<Sources: RandomAccessCollection>: Publisher where Sources.Element: Publisher {
        public typealias Output = [Sources.Element.Output]
        public typealias Failure = Sources.Element.Failure
        
        init(
            sources: Sources
        ) {
            self.sources = sources
        }
        
        public func receive(subscriber: some Subscriber<Output, Failure>) {
            subscriber.receive(subscription: CombineLatestSubscription(
                sources: sources,
                subscriber: subscriber
            ))
        }
        
        private final class CombineLatestSubscription<S: Subscriber<Output, Failure>>: Subscription {
            init(
                sources: Sources,
                subscriber: S
            ) {
                self.subscriber = subscriber
                
                _state = .init(wrappedValue: .init(
                    subscriptions: .init(repeating: nil, count: sources.count),
                    currentValues: .init(repeating: nil, count: sources.count)
                ))
                
                for (index, source) in sources.enumerated() {
                    source.receive(subscriber: CombineLatestSubscriber(
                        index: index,
                        subscriber: subscriber,
                        state: _state
                    ))
                }
            }
            
            func request(_ demand: Subscribers.Demand) {
                guard demand > .none else { return }
                
                let subscriptions = _state.write { state in
                    state.subscriptions.compact()
                }
                
                for subscription in subscriptions {
                    subscription.request(demand)
                }
            }
            
            func cancel() {
                let subscriptions = _state.write { state in
                    state.subscriptions
                        .compact()
                }
                
                subscriptions
                    .forEach { subscription in subscription.cancel() }
            }
  
            private struct State {
                var subscriptions: [Subscription?]
                var currentValues: [Sources.Element.Output?]
            }
            
            private final class CombineLatestSubscriber: Subscriber {
                typealias Input = Sources.Element.Output
                typealias Failure = Sources.Element.Failure
                
                init(
                    index: Int,
                    subscriber: S,
                    state: Synchronized<State>
                ) {
                    self.index = index
                    self.subscriber = subscriber
                    
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
                            return subscriber.receive(readyValues)
                        } else {
                            return .none
                        }
                    }
                }
                
                func receive(completion: Subscribers.Completion<Sources.Element.Failure>) {
                    let allFinished = _state.write { state in
                        if case .finished = completion {
                            state.subscriptions[index] = nil
                            
                            // The combined publisher is finished if either all of its upstream publishers are finished (the `subscriptions` are all `nil`) or if the one publisher that just finished here never published a value, since that means the combined publisher can never publish one either.
                            return state.currentValues[index] == nil || state.subscriptions
                                .lazy
                                .compact()
                                .isEmpty
                        }
                        
                        return false
                    }
                    
                    switch completion {
                        case let .failure(error):
                            subscriber.receive(completion: .failure(error))
                        case .finished:
                            if allFinished {
                                subscriber.receive(completion: .finished)
                            }
                    }
                }
                
                private let index: Int
                private let subscriber: S
                private let _state: Synchronized<State>
            }
            
            private let subscriber: S
            private let _state: Synchronized<State>
        }
        
        private let sources: Sources
    }
}
