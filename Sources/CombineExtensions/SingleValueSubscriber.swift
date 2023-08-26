import Combine
import Synchronization

// Allows receiving of just the next value from a publisher without having to retain and then throw away a Cancellable.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    @discardableResult
    func subscribeNext(
        receiveValue: @escaping (Output) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void
    ) -> some Cancellable {
        let subscriber = SingleValueSubscriber(
            receiveValue: receiveValue,
            receiveCompletion: receiveCompletion
        )
        
        subscribe(subscriber)
        
        return subscriber
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    @discardableResult
    func subscribeNext(
        receiveValue: @escaping (Output) -> Void
    ) -> some Cancellable {
        subscribeNext(
            receiveValue: receiveValue,
            receiveCompletion: { _ in }
        )
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class SingleValueSubscriber<Input, Failure: Error>: Subscriber, Cancellable {
    private enum State {
        case ready
        case subscribed(Subscription)
        case cancelled
    }
    
    init(
        receiveValue: @escaping (Input) -> Void,
        receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void
    ) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
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
        let send = _state.write { state in
            if case let .subscribed(subscription) = state {
                subscription.cancel()
                return true
            } else {
                return false
            }
        }
        
        if send {
            receiveValue(input)
        }
        
        return .none
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

    @Synchronized
    private var state: State = .ready
}

