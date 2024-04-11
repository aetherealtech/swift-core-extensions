import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private protocol Receiver<Output, Failure>: Sendable {
    associatedtype Output
    associatedtype Failure: Error
    
    func callAsFunction<S: Subscriber>(getSubscriber: () -> S?) async where S.Input == Output, S.Failure == Failure
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct NonThrowingReceiver<Output>: Receiver {
    typealias Failure = Never
    
    let work: @Sendable () async -> Output
    
    func callAsFunction<S: Subscriber>(getSubscriber: () -> S?) async where S.Input == Output, S.Failure == Failure {
        let result = await work()
        
        if let subscriber = getSubscriber() {
            _ = subscriber.receive(result)
            subscriber.receive(completion: .finished)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct ThrowingReceiver<Output>: Receiver {
    typealias Failure = any Error
    
    let work: @Sendable () async throws -> Output
    
    func callAsFunction<S: Subscriber>(getSubscriber: () -> S?) async where S.Input == Output, S.Failure == Failure {
        do {
            let result = try await work()
            
            if let subscriber = getSubscriber() {
                _ = subscriber.receive(result)
                subscriber.receive(completion: .finished)
            }
        } catch {
            if let subscriber = getSubscriber() {
                subscriber.receive(completion: .failure(error))
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncFuture<Output: Sendable, Failure: Error>: Publisher {
    fileprivate init(receiver: some Receiver<Output, Failure>) {
        self.receiver = receiver
    }
    
    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
        subscriber.receive(subscription: Subscription(
            subscriber: subscriber,
            receiver: receiver
        ))
    }
    
    private final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        init(
            subscriber: S,
            receiver: any Receiver<Output, Failure>
        ) {
            _state = .init(wrappedValue: .init(
                subscriber: subscriber,
                receiver: receiver
            ))
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else {
                return
            }
            
            _state.write { state in
                guard state.task == nil else {
                    return
                }
                
                state.task = .init { [_state, receiver = state.receiver] in
                    await receiver { _state.subscriber }
                }
            }
        }
        
        func cancel() {
            _state.write { state in
                state.subscriber = nil
                state.task?.cancel()
            }
        }
        
        private struct State {
            var subscriber: S?
            let receiver: any Receiver<Output, Failure>
            var task: Task<Void, Never>?
        }
        
        private let _state: Synchronized<State>
    }
    
    private let receiver: any Receiver<Output, Failure>
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncFuture where Failure == Never {
    init(_ work: @escaping @Sendable () async -> Output) {
        self.init(receiver: NonThrowingReceiver(work: work))
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncFuture where Failure == any Error {
    init(_ work: @escaping @Sendable () async throws -> Output) {
        self.init(receiver: ThrowingReceiver(work: work))
    }
}
