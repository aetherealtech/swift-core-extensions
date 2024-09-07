import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol AsyncFutureReceiver<Output, Failure>: Sendable {
    associatedtype Output
    associatedtype Failure: Error
    
    func callAsFunction<S: Subscriber<Output, Failure>>(getSubscriber: () -> S?) async
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct NonThrowingAsyncFutureReceiver<Output>: AsyncFutureReceiver {
    public typealias Failure = Never
    
    let work: @Sendable () async -> Output
    
    public func callAsFunction<S: Subscriber<Output, Failure>>(getSubscriber: () -> S?) async {
        let result = await work()
        
        if let subscriber = getSubscriber() {
            _ = subscriber.receive(result)
            subscriber.receive(completion: .finished)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ThrowingAsyncFutureReceiver<Output>: AsyncFutureReceiver {
    public typealias Failure = any Error
    
    let work: @Sendable () async throws -> Output
    
    public func callAsFunction<S: Subscriber<Output, Failure>>(getSubscriber: () -> S?) async {
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
private final class AsyncFutureSubscription<S: Subscriber, R: AsyncFutureReceiver<S.Input, S.Failure>>: Combine.Subscription {
    init(
        subscriber: S,
        receiver: R
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
        let receiver: R
        var task: Task<Void, Never>?
    }
    
    private let _state: Synchronized<State>
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncFuture<R: AsyncFutureReceiver>: Publisher {
    public typealias Output = R.Output
    public typealias Failure = R.Failure
    
    fileprivate init(receiver: R) {
        self.receiver = receiver
    }
    
    public func receive(subscriber: some Subscriber<Output, Failure>) {
        subscriber.receive(subscription: AsyncFutureSubscription(
            subscriber: subscriber,
            receiver: receiver
        ))
    }
    
    private let receiver: R
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncFuture {
    init<Output>(_ work: @escaping @Sendable () async -> Output) where R == NonThrowingAsyncFutureReceiver<Output> {
        self.init(receiver: .init(work: work))
    }
    
    init<Output>(_ work: @escaping @Sendable () async throws -> Output) where R == ThrowingAsyncFutureReceiver<Output> {
        self.init(receiver: .init(work: work))
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias NonThrowingAsyncFuture<Output> = AsyncFuture<NonThrowingAsyncFutureReceiver<Output>>

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias ThrowingAsyncFuture<Output> = AsyncFuture<ThrowingAsyncFutureReceiver<Output>>
