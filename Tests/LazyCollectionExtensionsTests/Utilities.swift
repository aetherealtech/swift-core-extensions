final class DestructiveSequence<Base: Sequence>: Sequence, IteratorProtocol {
    func next() -> Base.Element? {
        return iterator.next()
    }
    
    func makeIterator() -> Iterator {
        self
    }
    
    init(_ base: Base) {
        iterator = base.makeIterator()
    }
    
    private var iterator: Base.Iterator
}