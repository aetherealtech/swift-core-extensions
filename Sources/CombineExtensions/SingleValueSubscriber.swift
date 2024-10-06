import Combine
import Synchronization

// Allows receiving of just the next value from a publisher without having to retain and then throw away a Cancellable.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    @discardableResult
    func subscribeNext(
        receiveCompletion: @escaping @Sendable (Subscribers.Completion<Failure>) -> Void,
        receiveValue: @escaping @Sendable (Output) -> Void
    ) -> SingleValueSubscriber<Output, Failure>.CancelHandle {
        let subscriber = SingleValueSubscriber(
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion
        )
        
        subscribe(subscriber)
        
        return .init(subscriber: subscriber)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    @discardableResult
    func subscribeNext(
        receiveValue: @escaping @Sendable (Output) -> Void
    ) -> SingleValueSubscriber<Output, Failure>.CancelHandle {
        subscribeNext(
            receiveCompletion: { _ in },
            receiveValue: receiveValue
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct SingleValueSubscriber<Input, Failure: Error>: Subscriber, Sendable {
    public struct CancelHandle: Cancellable {
        init(subscriber: SingleValueSubscriber) {
            self.subscriber = subscriber
        }
        
        public func cancel() { subscriber.cancel() }
        
        private let subscriber: SingleValueSubscriber
    }

    public nonisolated(unsafe) let combineIdentifier = CombineIdentifier()

    public func receive(subscription: Subscription) {
        let cancelled = _state.write { state in
            state.subscription = subscription
            return state.cancelled
        }
        
        if cancelled {
            subscription.cancel()
        } else {
            subscription.request(.max(1))
        }
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        receiveValue(input)
        _state.subscription?.cancel()
        return .none
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
    }
    
    init(
        receiveValue: @escaping @Sendable (Input) -> Void,
        receiveCompletion: @escaping @Sendable (Subscribers.Completion<Failure>) -> Void
    ) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
    }
    
    func cancel() {
        let subscription = _state.write { state in
            state.cancelled = true
            return state.subscription
        }
        
        subscription?.cancel()
    }
    
    private struct State {
        var subscription: Subscription?
        var cancelled = false
    }

    private let receiveValue: @Sendable (Input) -> Void
    private let receiveCompletion: @Sendable (Subscribers.Completion<Failure>) -> Void

    private let _state: Synchronized<State> = .init(wrappedValue: .init())
}

