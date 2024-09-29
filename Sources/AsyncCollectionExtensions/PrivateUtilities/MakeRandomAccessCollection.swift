struct MakeRandomAccessSequence<Element: Sendable>: LazySequenceProtocol, Sendable {
    private struct _Iterator<Base: IteratorProtocol<Element>>: IteratorProtocol {
        mutating func next() -> Element? {
            base.next()
        }
        
        var base: Base
    }
    
    init<Base: Sequence<Element> & Sendable>(_ base: Base) {
        if let collection = base as? any RandomAccessCollection {
            _makeIterator = { .init(_Iterator(base: base.makeIterator())) }
            count = collection.count
        } else {
            let array = [Element].init(base)
            
            _makeIterator = { .init(_Iterator(base: array.makeIterator())) }
            count = array.count
        }
    }
    
    let count: Int
    
    func makeIterator() -> AnyIterator<Element> {
        _makeIterator()
    }
    
    private let _makeIterator: @Sendable () -> Iterator
}

extension Sequence where Self: Sendable, Element: Sendable {
    var makeRandomAccess: MakeRandomAccessSequence<Element> {
        .init(self)
    }
}
