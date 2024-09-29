struct LazySendableMapSequence<Base: Sequence & Sendable, Element>: LazySequenceProtocol {
    struct Iterator: IteratorProtocol {
        mutating func next() -> Element? {
            base.next().map(transform)
        }
        
        var base: Base.Iterator
        let transform: @Sendable (Base.Element) -> Element
    }
    
    func makeIterator() -> Iterator {
        .init(
            base: base.makeIterator(),
            transform: transform
        )
    }
    
    let base: Base
    let transform: @Sendable (Base.Element) -> Element
}

extension Sequence where Self: Sendable {
    func mapSendable<Result>(_ transform: @escaping @Sendable (Element) -> Result) -> LazySendableMapSequence<Self, Result> {
        .init(base: self, transform: transform)
    }
}
