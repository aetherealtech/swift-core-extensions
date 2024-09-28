public struct LazyTerminatingSequence<
    Base: Sequence
>: LazySequenceProtocol {
    public typealias Element = Base.Element
    
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Element? {
            guard let next = base.next(), !terminateCondition(next) else {
                return nil
            }
            
            return next
        }
        
        var base: Base.Iterator
        let terminateCondition: (Element) -> Bool
    }
    
    public func makeIterator() -> Iterator {
        .init(
            base: base.makeIterator(),
            terminateCondition: terminateCondition
        )
    }
    
    let base: Base
    let terminateCondition: (Element) -> Bool
}

public extension LazySequenceProtocol {
    func terminate(when condition: @escaping (Element) -> Bool) -> LazyTerminatingSequence<Elements> {
        .init(
            base: elements,
            terminateCondition: condition
        )
    }
}
