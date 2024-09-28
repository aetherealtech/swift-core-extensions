public struct LazyInsertedSequence<
    Source: Sequence,
    Inserted: Sequence<Source.Element>
>: LazySequenceProtocol {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Source.Element? {
            if remainingUntilInsert == 0 {
                return inserted.next() ?? source.next()
            } else {
                remainingUntilInsert -= 1
                return source.next()
            }
        }
        
        var source: Source.Iterator
        var inserted: Inserted.Iterator
        var remainingUntilInsert: Int
    }
    
    public func makeIterator() -> Iterator {
        .init(
            source: source.makeIterator(),
            inserted: inserted.makeIterator(),
            remainingUntilInsert: insertAt
        )
    }
    
    let source: Source
    let inserted: Inserted
    let insertAt: Int
}
