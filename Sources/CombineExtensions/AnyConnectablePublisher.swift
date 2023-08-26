import Combine

/// enables ConnectablePublishers to be wrapped in the same way instances of Publisher can be wrapped in AnyPublisher.
/// This gives API designers the ability to hide implementation details behind a type-erased facade while not giving up the power of ConnectablePublisher.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension ConnectablePublisher {
    func eraseToAnyConnectablePublisher() -> AnyConnectablePublisher<Output, Failure> {
        AnyConnectablePublisher(erasing: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class AnyConnectablePublisher<Output, Failure: Error>: ConnectablePublisher {
    public init<P: ConnectablePublisher>(
        erasing: P
    ) where P.Output == Output, P.Failure == Failure {
        erased = erasing.eraseToAnyPublisher()
        connectImp = { erased in (erased as! P).connect() }
    }

    public func connect() -> Cancellable {
        connectImp(erased)
    }

    public func receive<S>(subscriber: S) where S: Combine.Subscriber, S.Failure == Failure, S.Input == Output {
        erased.receive(subscriber: subscriber)
    }
    
    private let erased: AnyPublisher<Output, Failure>
    private let connectImp: (AnyPublisher<Output, Failure>) -> Cancellable
}
