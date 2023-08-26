import Combine

// Allows receiving of just the next value from a publisher without having to retain and then throw away a Cancellable.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func subscribeNext(
        receiveValue: @escaping (Output) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void
    ) {
        subscribe(SingleValueSubscriber(
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion
        ))
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    func subscribeNext(
        receiveValue: @escaping (Output) -> Void
    ) {
        subscribeNext(
            receiveValue: receiveValue,
            receiveCompletion: { _ in }
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SingleValueSubscriber<Input, Failure: Error>: Subscriber {
    init(
        receiveValue: @escaping (Input) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void
    ) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.max(1))
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        receiveValue(input)
        subscription?.cancel()
        return .none
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
        subscription?.cancel()
    }

    private let receiveValue: (Input) -> Void
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void

    private var subscription: Subscription?
}

