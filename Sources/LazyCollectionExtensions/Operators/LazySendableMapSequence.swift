public struct LazySendableMapSequence<
    Base: Sequence & Sendable,
    Element
>: LazySequenceProtocol, Sendable {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Element? {
            base.next().map(transform)
        }
        
        var base: Base.Iterator
        let transform: (Base.Element) -> Element
    }
    
    public func makeIterator() -> Iterator {
        .init(
            base: base.makeIterator(),
            transform: transform
        )
    }
    
    let base: Base
    let transform: @Sendable (Base.Element) -> Element
}

public extension LazySequenceProtocol {
    func map<Result>(_ transform: @escaping @Sendable (Element) -> Result) -> LazySendableMapSequence<Elements, Result> {
        .init(
            base: elements,
            transform: transform
        )
    }
}
