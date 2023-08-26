import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnySubscription: Subscription {
    public var combineIdentifier: CombineIdentifier {
        combineIdentifier_get(erased)
    }
    
    public func request(_ demand: Subscribers.Demand) {
        request_imp(erased, demand)
    }
    
    public func cancel() {
        cancel_imp(erased)
    }
    
    init<Erasing: Subscription>(erasing: Erasing) {
        erased = erasing
        
        combineIdentifier_get = { erased in (erased as! Erasing).combineIdentifier }
        request_imp = { erased, demand in (erased as! Erasing).request(demand) }
        cancel_imp = { erased in (erased as! Erasing).cancel() }
    }
    
    private var erased: Any
    
    private let combineIdentifier_get: (Any) -> CombineIdentifier
    private let request_imp: (Any, Subscribers.Demand) -> Void
    private let cancel_imp: (Any) -> Void
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Subscription {
    func eraseToAnySubscription() -> AnySubscription {
        .init(erasing: self)
    }
}
