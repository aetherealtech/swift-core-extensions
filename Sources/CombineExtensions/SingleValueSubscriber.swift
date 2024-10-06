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
        _state.write { state in
            switch state {
                case .cancelled:
                    subscription.cancel()
                default:
                    state = .subscribed(subscription)
                    subscription.request(.max(1))
            }
        }
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        receiveValue(input)
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
        _state.write { state in
            if case let .subscribed(subscription) = state {
                subscription.cancel()
            }
            
            state = .cancelled
        }
    }
    
    private enum State {
        case ready
        case subscribed(Subscription)
        case cancelled
    }

    private let receiveValue: @Sendable (Input) -> Void
    private let receiveCompletion: @Sendable (Subscribers.Completion<Failure>) -> Void

    private let _state: Synchronized<State> = .init(wrappedValue: .ready)
}

