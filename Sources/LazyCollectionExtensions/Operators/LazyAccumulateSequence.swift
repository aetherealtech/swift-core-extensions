public struct LazyAccumulateSequence<
    Source: Sequence,
    Element
>: LazySequenceProtocol {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Element? {
            guard let current else {
                return nil
            }
                        
            self.current = source.next().map { next in accumulator(current, next) }
            
            return current
        }
        
        var source: Source.Iterator
        var current: Element?
        let accumulator: (Element, Source.Element) -> Element
    }
    
    public func makeIterator() -> Iterator {
        .init(
            source: source.makeIterator(),
            current: initial,
            accumulator: accumulator
        )
    }
    
    let source: Source
    let initial: Element
    let accumulator: (Element, Source.Element) -> Element
}
