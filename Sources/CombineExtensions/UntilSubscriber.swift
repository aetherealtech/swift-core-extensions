import Combine
import Synchronization

// Subscribes to a publisher until a published value meets a condition, at which point it cancels itself.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    @discardableResult
    func subscribe(
        receiveValue: @escaping (Output) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
        until: @escaping (Output) -> Bool
    ) -> some Cancellable {
        let subscriber = UntilSubscriber(
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion,
            until: until
        )
        
        subscribe(subscriber)
        
        return subscriber
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    @discardableResult
    func subscribe(
        receiveValue: @escaping (Output) -> Void,
        until: @escaping (Output) -> Bool
    ) -> some Cancellable {
        subscribe(
            receiveValue: receiveValue,
            receiveCompletion: { _ in },
            until: until
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class UntilSubscriber<Input, Failure: Error>: Subscriber, Cancellable {
    private enum State {
        case ready
        case subscribed(Subscription)
        case cancelled
    }
    
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

    func receive(_ input: Input) -> Subscribers.Demand {
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

    func receive(completion: Subscribers.Completion<Failure>) {
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

    func cancel() {
        _state.write { state in
            if case let .subscribed(subscription) = state {
                subscription.cancel()
            }
            
            state = .cancelled
        }
    }
    
    private let receiveValue: (Input) -> Void
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    private let until: (Input) -> Bool

    @Synchronized
    private var state: State = .ready
}
