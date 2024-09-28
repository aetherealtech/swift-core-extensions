public struct LazySendableFilterSequence<
    Base: Sequence & Sendable
>: LazySequenceProtocol, Sendable {
    public typealias Element = Base.Element
    
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Element? {
            while let next = base.next() {
                if condition(next) {
                    return next
                }
            }
            
            return nil
        }
        
        var base: Base.Iterator
        let condition: (Element) -> Bool
    }
    
    public func makeIterator() -> Iterator {
        .init(
            base: base.makeIterator(),
            condition: condition
        )
    }
    
    let base: Base
    let condition: @Sendable (Element) -> Bool
}

public extension LazySequenceProtocol where Elements: Sendable {
    func filterSendable(_ condition: @escaping @Sendable (Element) -> Bool) -> LazySendableFilterSequence<Elements> {
        .init(
            base: elements,
            condition: condition
        )
    }
}
