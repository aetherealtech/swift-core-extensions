public protocol TerminateCondition<Element> {
    associatedtype Element
    
    func callAsFunction(_ element: Element) -> Bool
}

public struct NonSendableTerminateCondition<Element>: TerminateCondition {
    public func callAsFunction(_ element: Element) -> Bool {
        _closure(element)
    }
    
    let _closure: (Element) -> Bool
}

public struct SendableTerminateCondition<Element>: TerminateCondition, Sendable {
    public func callAsFunction(_ element: Element) -> Bool {
        _closure(element)
    }
    
    let _closure: @Sendable (Element) -> Bool
}

public struct LazyTerminatingSequence<
    Base: Sequence,
    Condition: TerminateCondition<Base.Element>
>: LazySequenceProtocol {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Base.Element? {
            guard let next = base.next(), !terminateCondition(next) else {
                return nil
            }
            
            return next
        }
        
        var base: Base.Iterator
        let terminateCondition: Condition
    }
    
    public func makeIterator() -> Iterator {
        .init(
            base: base.makeIterator(),
            terminateCondition: terminateCondition
        )
    }
    
    let base: Base
    let terminateCondition: Condition
}

extension LazyTerminatingSequence: Sendable where Base: Sendable, Condition: Sendable {}

public extension LazySequenceProtocol {
    func terminate(when condition: @escaping (Element) -> Bool) -> LazyTerminatingSequence<Elements, NonSendableTerminateCondition<Element>> {
        .init(
            base: elements,
            terminateCondition: .init(_closure: condition)
        )
    }
    
    func terminateSendable(when condition: @escaping @Sendable (Element) -> Bool) -> LazyTerminatingSequence<Elements, SendableTerminateCondition<Element>> {
        .init(
            base: elements,
            terminateCondition: .init(_closure: condition)
        )
    }
}
