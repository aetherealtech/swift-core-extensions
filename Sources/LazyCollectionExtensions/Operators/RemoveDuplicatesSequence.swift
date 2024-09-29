public struct RemoveDuplicatesSequence<
    Source: Sequence
>: LazySequenceProtocol {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Source.Element? {
            while let next = source.next() {
                if !found.contains(where: { checking in compare(next, checking) }) {
                    found.append(next)
                    return next
                }
            }
            
            return nil
        }
        
        var source: Source.Iterator
        var compare: (Element, Element) -> Bool
        var found: [Element] = []
    }
    
    public func makeIterator() -> Iterator {
        .init(
            source: source.makeIterator(),
            compare: compare
        )
    }
    
    let source: Source
    var compare: (Element, Element) -> Bool
}
