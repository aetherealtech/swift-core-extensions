public struct LazySendableFlattenSequence<
    Base: Sequence & Sendable
>: LazySequenceProtocol, Sendable where Base.Element: Sequence {
    public typealias Element = Base.Element.Element
    
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Element? {
            var next = inner?.next()
            
            while next == nil, let nextOuter = base.next() {
                inner = nextOuter.makeIterator()
                next = inner?.next()
            }
            
            return next
        }
        
        var base: Base.Iterator
        var inner: Base.Element.Iterator?
    }
    
    public func makeIterator() -> Iterator {
        .init(
            base: base.makeIterator()
        )
    }
    
    let base: Base
}

// Same as `map`, this also compiles without the constraint.
public extension LazySequenceProtocol where Elements: Sendable {
    func flattenSendable<InnerElement>() -> LazySendableFlattenSequence<Elements> where Element: Sequence, Element.Element == InnerElement {
        .init(
            base: elements
        )
    }
    
    func flatMapSendable<Result: Sequence>(_ transform: @escaping @Sendable (Element) -> Result) -> LazySendableFlattenSequence<LazySendableMapSequence<Elements, Result>> {
        mapSendable(transform)
            .flattenSendable()
    }
}
