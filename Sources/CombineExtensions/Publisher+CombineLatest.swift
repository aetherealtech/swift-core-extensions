import CollectionExtensions
import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Collection where Element: Publisher {
    func combineLatest() -> some Publisher<[Element.Output], Element.Failure> {
        CombineLatestPublisher(sources: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct CombineLatestPublisher<Sources: Collection>: Publisher where Sources.Element: Publisher {
    typealias Output = [Sources.Element.Output]
    typealias Failure = Sources.Element.Failure

    init(
        sources: Sources
    ) {
        self.sources = sources
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
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
                subscriptions: sources.map { _ in nil },
                currentValues: sources.map { _ in nil }
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
                fatalError("combineLatest currently only supports unlimited demand subscribers")
            }
        }

        func cancel() {
            _state.write { state in
                state.subscriptions.compact().forEach { subscription in subscription.cancel() }
                state.subscriptions = (0 ..< state.subscriptions.count).map { _ in nil }
                state.subscriber = nil
            }
        }

        private func makeSubscriber(index: Int, source: Sources.Element) -> CombineLatestSubscriber {
            CombineLatestSubscriber(
                source: source,
                index: index,
                receiveSubscription: { [weak self] index, subscription in
                    self?._state.subscriptions[index] = subscription
                },
                receiveValue: { [weak self] index, value in
                    guard let strongSelf = self else {
                        return .none
                    }

                    return strongSelf._state.write { state -> Subscribers.Demand in
                        state.currentValues[index] = value

                        let readyValues = state.currentValues.compact()
                        if readyValues.count == state.currentValues.count {
                            _ = state.subscriber?.receive(readyValues)
                        }

                        return .none
                    }
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

        private struct State { // swiftlint:disable:this nesting
            var subscriber: S?
            var subscriptions: [Subscription?]
            var currentValues: [Sources.Element.Output?]
        }

        private class CombineLatestSubscriber: Subscriber { // swiftlint:disable:this nesting
            typealias Input = Sources.Element.Output // swiftlint:disable:this nesting
            typealias Failure = Sources.Element.Failure // swiftlint:disable:this nesting

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
