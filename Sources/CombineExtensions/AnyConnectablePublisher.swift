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
public struct AnyConnectablePublisher<Output, Failure: Error>: ConnectablePublisher {
    public init<P: ConnectablePublisher<Output, Failure>>(
        erasing: P
    ) {
        unwrap = erasing
    }

    public func connect() -> any Cancellable {
        unwrap.connect()
    }

    public func receive(subscriber: some Subscriber<Output, Failure>) {
        unwrap.receive(subscriber: subscriber)
    }
    
    public let unwrap: any ConnectablePublisher<Output, Failure>
}
