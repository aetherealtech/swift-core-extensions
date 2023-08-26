import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Collection where Element: Publisher {
    func merge() -> some Publisher<Element.Output, Element.Failure> {
        MergePublisher(sources: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct MergePublisher<Sources: Collection>: Publisher where Sources.Element: Publisher {
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
                subscriber: subscriber,
                subscriptions: sources.map { _ in nil }
            )

            sources.enumerated().forEach { index, source in

                source.receive(subscriber: makeSubscriber(index: index, source: source))
            }
        }

        func request(_ demand: Subscribers.Demand) {
            if demand == .none {
                return
            } else if demand == .unlimited {
                let subscriptions = _state.write { state -> [Subscription] in
                    state.subscriptions.compact()
                }

                subscriptions.forEach { subscription in subscription.request(.unlimited) }
            } else {
                fatalError("merge currently only supports unlimited demand subscribers")
            }
        }

        func cancel() {
            _state.write { state in
                state.subscriptions.compact().forEach { subscription in subscription.cancel() }
                state.subscriptions = (0 ..< state.subscriptions.count).map { _ in nil }
                state.subscriber = nil
            }
        }

        private func makeSubscriber(index: Int, source: Sources.Element) -> MergeSubscriber {
            MergeSubscriber(
                source: source,
                index: index,
                receiveSubscription: { [weak self] index, subscription in
                    self?._state.subscriptions[index] = subscription
                },
                receiveValue: { [weak self] _, value in
                    guard let strongSelf = self else {
                        return .none
                    }

                    _ = strongSelf._state.subscriber?.receive(value)

                    return .none
                },
                receiveCompletion: { [weak self] index, completion in
                    if case .failure = completion {
                        self?._state.subscriber?.receive(completion: completion)
                        return
                    }

                    self?._state.write { state in
                        state.subscriptions[index] = nil

                        if state.subscriptions.compact().isEmpty {
                            state.subscriber?.receive(completion: .finished)
                        }
                    }
                }
            )
        }

        private struct State {
            var subscriber: S?
            var subscriptions: [Subscription?]
        }

        private class MergeSubscriber: Subscriber {
            typealias Input = Sources.Element.Output
            typealias Failure = Sources.Element.Failure

            init(
                source _: Sources.Element,
                index: Int,
                receiveSubscription: @escaping (Int, Subscription) -> Void,
                receiveValue: @escaping (Int, Sources.Element.Output) -> Subscribers.Demand,
                receiveCompletion: @escaping (Int, Subscribers.Completion<Sources.Element.Failure>) -> Void
            ) {
                self.index = index

                self.receiveSubscription = receiveSubscription
                self.receiveValue = receiveValue
                self.receiveCompletion = receiveCompletion
            }

            func receive(subscription: Subscription) {
                receiveSubscription(index, subscription)
            }

            func receive(_ input: Sources.Element.Output) -> Subscribers.Demand {
                receiveValue(index, input)
            }

            func receive(completion: Subscribers.Completion<Sources.Element.Failure>) {
                receiveCompletion(index, completion)
            }

            private let index: Int

            private let receiveSubscription: (Int, Subscription) -> Void
            private let receiveValue: (Int, Sources.Element.Output) -> Subscribers.Demand
            private let receiveCompletion: (Int, Subscribers.Completion<Sources.Element.Failure>) -> Void
        }

        @Synchronized private var state: State
    }

    private let sources: Sources
}
