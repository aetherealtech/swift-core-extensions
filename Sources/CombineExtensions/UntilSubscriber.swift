import Combine

// Subscribes to a publisher until a published value meets a condition, at which point it cancels itself.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func subscribe(
        receiveValue: @escaping (Output) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
        until: @escaping (Output) -> Bool
    ) {
        subscribe(UntilSubscriber(
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion,
            until: until
        ))
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    func subscribe(
        receiveValue: @escaping (Output) -> Void,
        until: @escaping (Output) -> Bool
    ) {
        subscribe(
            receiveValue: receiveValue,
            receiveCompletion: { _ in },
            until: until
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class UntilSubscriber<Input, Failure: Error>: Subscriber {
    init(
        receiveValue: @escaping (Input) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
        until: @escaping (Input) -> Bool
    ) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
        self.until = until
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.max(1))
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        receiveValue(input)
        if until(input) {
            subscription?.cancel()
            return .none
        } else {
            return .max(1)
        }
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
        subscription?.cancel()
    }

    private let receiveValue: (Input) -> Void
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    private let until: (Input) -> Bool

    private var subscription: Subscription?
}
