import Combine

struct TestError: Error {}

final class NoDemandSubscriber<Input, Failure: Error>: Subscriber {
    func receive(subscription: any Subscription) { subscription.request(.none) }
    
    func receive(_ input: Input) -> Subscribers.Demand { received.append(input); return .none }
    
    func receive(completion: Subscribers.Completion<Failure>) { }
    
    let combineIdentifier = CombineIdentifier()
    
    var received: [Input] = []
}

extension Publisher {
    func subscribeNoDemand() -> NoDemandSubscriber<Output, Failure> {
        let subscriber = NoDemandSubscriber<Output, Failure>()
        receive(subscriber: subscriber)
        return subscriber
    }
}

final class ManualDemandSubscriber<Input, Failure: Error>: Subscriber {
    init(receiveValue: @escaping @Sendable (Input) -> Void) {
        self.receiveValue = receiveValue
    }
    
    func receive(subscription: any Subscription) { self.subscription = subscription }
    func receive(_ input: Input) -> Subscribers.Demand { receiveValue(input); return .none }
    func receive(completion: Subscribers.Completion<Failure>) { }
    
    let combineIdentifier = CombineIdentifier()
    
    func request(demand: Subscribers.Demand) { subscription!.request(demand) }
    
    private let receiveValue: @Sendable (Input) -> Void
    private var subscription: (any Subscription)?
}

extension Publisher {
    func subscribeManualDemand(
        receiveValue: @escaping @Sendable (Output) -> Void
    ) -> ManualDemandSubscriber<Output, Failure> {
        let subscriber = ManualDemandSubscriber<Output, Failure>(receiveValue: receiveValue)
        receive(subscriber: subscriber)
        return subscriber
    }
}
