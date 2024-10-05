import CollectionExtensions
import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Collection where Element: Publisher {
    func combineLatest() -> Publishers.CombineLatestCollection<Self> {
        .init(sources: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publishers {
    struct CombineLatestCollection<Sources: Collection>: Publisher where Sources.Element: Publisher {
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
                _state = .init(wrappedValue: .init(
                    subscriber: subscriber,
                    subscriptions: .init(repeating: nil, count: sources.count),
                    currentValues: .init(repeating: nil, count: sources.count)
                ))
                
                sources.enumerated().forEach { index, source in
                    source.receive(subscriber: CombineLatestSubscriber(
                        index: index,
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
                _state.write { state in
                    state.subscriptions.forEach { subscription in subscription?.cancel() }
                }
            }
  
            private struct State {
                var subscriber: S
                var subscriptions: [Subscription?]
                var currentValues: [Sources.Element.Output?]
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
                            return state.subscriber.receive(readyValues)
                        } else {
                            return .none
                        }
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
                
                private let _state: Synchronized<State>
            }
            
            private let _state: Synchronized<State>
        }
        
        private let sources: Sources
    }
}
