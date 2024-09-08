import Combine
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol AsyncFutureReceiver<Output, Failure>: Sendable {
    associatedtype Output
    associatedtype Failure: Error
    
    func callAsFunction<S: Subscriber<Output, Failure>>() async -> (S) -> Void
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct NonThrowingAsyncFutureReceiver<Output>: AsyncFutureReceiver {
    public typealias Failure = Never
    
    let work: @Sendable () async -> Output
    
    public func callAsFunction<S: Subscriber<Output, Failure>>() async -> (S) -> Void {
        let result = await work()
        
        return { subscriber in
            _ = subscriber.receive(result)
            subscriber.receive(completion: .finished)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct ThrowingAsyncFutureReceiver<Output>: AsyncFutureReceiver {
    public typealias Failure = any Error
    
    let work: @Sendable () async throws -> Output
    
    public func callAsFunction<S: Subscriber<Output, Failure>>() async -> (S) -> Void {
        do {
            let result = try await work()
            
            return { subscriber in
                _ = subscriber.receive(result)
                subscriber.receive(completion: .finished)
            }
        } catch {
            return { subscriber in
                subscriber.receive(completion: .failure(error))
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct SendableSubscriber<S: Subscriber>: @unchecked Sendable {
    let value: S
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct AsyncFutureSubscription<S: Subscriber, R: AsyncFutureReceiver<S.Input, S.Failure>>: Combine.Subscription {
    init(
        subscriber: S,
        receiver: R
    ) {
        self.subscriber = subscriber
        self.receiver = receiver
    }
    
    var combineIdentifier: CombineIdentifier { subscriber.combineIdentifier }

    func request(_ demand: Subscribers.Demand) {
        guard demand > .none else {
            return
        }
        
        _task.write { task in
            guard task == nil else {
                return
            }
                        
            task = .init { [subscriber = SendableSubscriber(value: subscriber), receiver] in
                let receiveValue: (S) -> Void = await receiver()
                
                try? Task.checkCancellation()
                
                receiveValue(subscriber.value)
            }
        }
    }
    
    func cancel() {
        _task.write { task in
            task?.cancel()
            task = nil
        }
    }

    private let subscriber: S
    private let receiver: R
    
    private let _task: Synchronized<Task<Void, Never>?> = .init(wrappedValue: nil)
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
