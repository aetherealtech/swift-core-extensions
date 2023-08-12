public struct LazyTerminatingSequence<Base: LazySequenceProtocol>: LazySequenceProtocol {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Base.Element? {
            guard let next = base.next(), !terminateCondition(next) else {
                return nil
            }
            
            return next
        }
        
        var base: Base.Iterator
        let terminateCondition: (Base.Element) -> Bool
    }
    
    public func makeIterator() -> Iterator {
        .init(
            base: base.makeIterator(),
            terminateCondition: terminateCondition
        )
    }
    
    let base: Base
    let terminateCondition: (Base.Element) -> Bool
}

public extension LazySequenceProtocol {
    func terminate(when condition: @escaping (Element) -> Bool) -> LazyTerminatingSequence<Self> {
        .init(
            base: self,
            terminateCondition: condition
        )
    }
}
