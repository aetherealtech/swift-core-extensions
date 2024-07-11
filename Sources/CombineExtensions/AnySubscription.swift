import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnySubscription: Subscription {
    public var combineIdentifier: CombineIdentifier {
        unwrap.combineIdentifier
    }
    
    public func request(_ demand: Subscribers.Demand) {
        unwrap.request(demand)
    }
    
    public func cancel() {
        unwrap.cancel()
    }
    
    init<Erasing: Subscription>(erasing: Erasing) {
        unwrap = erasing
    }
    
    public let unwrap: any Subscription
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Subscription {
    func eraseToAnySubscription() -> AnySubscription {
        .init(erasing: self)
    }
}
