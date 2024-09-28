public struct LazySendableFlatMapSequence<
    Base: Sequence & Sendable,
    Result: Sequence
>: LazySequenceProtocol, Sendable {
    public typealias Element = Result.Element
    
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Element? {
            var next = inner?.next()
            
            while next == nil, let nextOuter = base.next() {
                inner = transform(nextOuter).makeIterator()
                next = inner?.next()
            }
            
            return next
        }
        
        var base: Base.Iterator
        var inner: Result.Iterator?
        let transform: (Base.Element) -> Result
    }
    
    public func makeIterator() -> Iterator {
        .init(
            base: base.makeIterator(),
            transform: transform
        )
    }
    
    let base: Base
    let transform: @Sendable (Base.Element) -> Result
}

public extension LazySequenceProtocol {
    func flatMap<Result: Sequence>(_ transform: @escaping @Sendable (Element) -> Result) -> LazySendableFlatMapSequence<Elements, Result> {
        .init(
            base: elements,
            transform: transform
        )
    }
}
