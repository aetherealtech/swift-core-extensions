import AsyncExtensions
import Combine
import Synchronization

// WARNING - This is not covered by unit tests and may suffer from subtle bugs.
// If you want to use it in production code, you should add thorough test cases first (including making sure a stream's completion is always received *after* all the mapped values are received)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Publisher {
    func await<R>() -> AnyPublisher<R, Failure> where Output == () async -> R {
        TryAwaitPublisher<Self, R, AwaitReceive<R, Failure>>(
            source: self
        )
        .eraseToAnyPublisher() // Erasing works around compiler crash
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Error {
    func await<R>() -> AnyPublisher<R, Error> where Output == () async throws -> R {
        TryAwaitPublisher<Self, R, TryAwaitReceive<R>>(
            source: self
        )
        .eraseToAnyPublisher() // Erasing works around compiler crash
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct TryAwaitPublisher<Source: Publisher, Output, ReceiveMethod: AwaitReceiveMethod>:
    Publisher where ReceiveMethod.Output == Output, Source.Output == ReceiveMethod.SourceOutput, ReceiveMethod.SubscriberFailure == Source.Failure {
    typealias Failure = Source.Failure

    init(
        source: Source
    ) {
        self.source = source
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        subscriber.receive(subscription: AwaitSubscription(
            source: source,
            subscriber: subscriber
        ))
    }

    private final class AwaitSubscription<S: Subscriber>: Subscriber, Subscription where S.Input == Output, S.Failure == Failure {
        typealias Input = Source.Output
        typealias Failure = Source.Failure

        init(
            source: Source,
            subscriber: S
        ) {
            state = .init(subscriber: subscriber)

            source.receive(subscriber: self)
        }

        func receive(subscription: Subscription) {
            _state.subscription = subscription
        }

        func receive(_ input: Source.Output) -> Subscribers.Demand {
            _state.write { state in
                guard let subscriber = state.subscriber, state.demand >= 0 else {
                    return .none
                }

                state.demand -= 1

                state.pendingValues.append({
                    await ReceiveMethod.awaitReceive(
                        subscriber: subscriber,
                        input: input,
                        request: self.request
                    )
                })

                return .none
            }
        }

        func receive(completion: Subscribers.Completion<Source.Failure>) {
            Task {
                _ = await self.state.pendingValues.awaitAll()
                self.state.subscriber?.receive(completion: completion)
            }
        }

        func request(_ demand: Subscribers.Demand) {
            let subscription = _state.write { state in
                state.demand += demand
                return state.subscription
            }

            subscription?.request(demand)
        }

        func cancel() {
            _state.write { state in
                state.subscription?.cancel()
                state.subscription = nil
                state.subscriber = nil
            }
        }

        private struct State {
            var subscriber: S?
            var subscription: Subscription?
            var demand: Subscribers.Demand = .none
            var pendingValues = [() async -> Void]()
        }

        @Synchronized private var state: State
    }

    private let source: Source
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public protocol AwaitReceiveMethod {
    associatedtype SubscriberFailure: Error

    associatedtype Output
    associatedtype SourceOutput

    static func awaitReceive<S: Subscriber>(
        subscriber: S,
        input: SourceOutput,
        request: (Subscribers.Demand) -> Void
    ) async where S.Input == Output, S.Failure == SubscriberFailure
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum AwaitReceive<Output, SubscriberFailure: Error>: AwaitReceiveMethod {
    public static func awaitReceive<S: Subscriber>(
        subscriber: S,
        input: () async -> Output,
        request: (Subscribers.Demand) -> Void
    ) async where S.Input == Output, S.Failure == SubscriberFailure {
        let extra = await subscriber.receive(input())
        if extra > 0 {
            request(extra)
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum TryAwaitReceive<Output>: AwaitReceiveMethod {
    public typealias SubscriberFailure = Error

    public static func awaitReceive<S: Subscriber>(
        subscriber: S,
        input: () async throws -> Output,
        request: (Subscribers.Demand) -> Void
    ) async where S.Input == Output, S.Failure == SubscriberFailure {
        do {
            let extra = try await subscriber.receive(input())
            if extra > 0 {
                request(extra)
            }
        } catch {
            subscriber.receive(completion: .failure(error))
        }
    }
}
