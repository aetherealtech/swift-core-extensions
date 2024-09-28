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

extension LazySendableMapSequence: Collection where Base: Collection {
    public typealias Index = Base.Index
    public typealias Indices = Base.Indices
    
    public var startIndex: Base.Index { base.startIndex }
    public var endIndex: Base.Index { base.endIndex }
    
    public func index(after i: Base.Index) -> Base.Index { base.index(after: i) }

    public var indices: Base.Indices { base.indices }

    public subscript(position: Base.Index) -> Element {
        _read { yield transform(base[position]) }
    }
}

extension LazySendableMapSequence: BidirectionalCollection where Base: BidirectionalCollection {
    public func index(before i: Base.Index) -> Base.Index { base.index(before: i) }
}

extension LazySendableMapSequence: RandomAccessCollection where Base: RandomAccessCollection {
    public func index(_ i: Base.Index, offsetBy distance: Int) -> Base.Index { base.index(i, offsetBy: distance) }
    public func index(_ i: Base.Index, offsetBy distance: Int, limitedBy limit: Base.Index) -> Base.Index? { base.index(i, offsetBy: distance, limitedBy: limit) }
}

// This compiles without the constraint, but I think that's a compiler bug.  The constraint *is* required on `filter`.
public extension LazySequenceProtocol where Elements: Sendable {
    func map<Result>(_ transform: @escaping @Sendable (Element) -> Result) -> LazySendableMapSequence<Elements, Result> {
        .init(
            base: elements,
            transform: transform
        )
    }
}
