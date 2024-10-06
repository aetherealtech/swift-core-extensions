import Combine
import Synchronization

// Subscribes to a publisher until a published value meets a condition, at which point it cancels itself.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    @discardableResult
    func subscribe(
        receiveValue: @escaping @Sendable (Output) -> Void,
        receiveCompletion: @escaping @Sendable (Subscribers.Completion<Failure>) -> Void,
        until: @escaping @Sendable (Output) -> Bool
    ) -> UntilSubscriber<Output, Failure>.CancelHandle {
        let subscriber = UntilSubscriber(
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion,
            until: until
        )
        
        subscribe(subscriber)
        
        return .init(subscriber: subscriber)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    @discardableResult
    func subscribe(
        receiveValue: @escaping @Sendable (Output) -> Void,
        until: @escaping @Sendable (Output) -> Bool
    ) -> UntilSubscriber<Output, Failure>.CancelHandle {
        subscribe(
            receiveValue: receiveValue,
            receiveCompletion: { _ in },
            until: until
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct UntilSubscriber<Input, Failure: Error>: Subscriber, Cancellable, Sendable {
    public struct CancelHandle: Cancellable {
        init(subscriber: UntilSubscriber) {
            self.subscriber = subscriber
        }
        
        public func cancel() { subscriber.cancel() }
        
        private let subscriber: UntilSubscriber
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
        let (send, extra) = _state.write { state -> (Bool, Subscribers.Demand) in
            if case let .subscribed(subscription) = state {
                let stop = until(input)
                if stop {
                    subscription.cancel()
                }
                return (true, stop ? .none : .max(1))
            } else {
                return (false, .none)
            }
        }
        
        if send {
            receiveValue(input)
        }

        return extra
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        let send = _state.write { state in
            if case let .subscribed(subscription) = state {
                subscription.cancel()
                return true
            } else {
                return false
            }
        }
        
        if send {
            receiveCompletion(completion)
        }
    }

    public func cancel() {
        _state.write { state in
            if case let .subscribed(subscription) = state {
                subscription.cancel()
            }
            
            state = .cancelled
        }
    }
    
    init(
        receiveValue: @escaping @Sendable (Input) -> Void,
        receiveCompletion: @escaping @Sendable (Subscribers.Completion<Failure>) -> Void,
        until: @escaping @Sendable (Input) -> Bool
    ) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
        self.until = until
    }
    
    private enum State {
        case ready
        case subscribed(Subscription)
        case cancelled
    }
    
    private let receiveValue: @Sendable (Input) -> Void
    private let receiveCompletion: @Sendable (Subscribers.Completion<Failure>) -> Void
    private let until: @Sendable (Input) -> Bool

    private let _state: Synchronized<State> = .init(wrappedValue: .ready)
}
