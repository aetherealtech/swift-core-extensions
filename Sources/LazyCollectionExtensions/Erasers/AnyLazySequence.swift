public struct AnyLazySequence<Element>: LazySequenceProtocol {
    public typealias Iterator = AnyIterator<Element>
    
    public func makeIterator() -> AnyIterator<Element> {
        makeIteratorImp(base)
    }
    
    init<Base: LazySequenceProtocol>(_ base: Base) where Base.Element == Element {
        self.base = base
        makeIteratorImp = { base in (base as! Base).makeIterator().erase() }
    }
    
    public let base: any LazySequenceProtocol
    
    private let makeIteratorImp: (any LazySequenceProtocol) -> Iterator
}

public extension LazySequenceProtocol {
    func lazyErase() -> AnyLazySequence<Element> {
        .init(self)
    }
}

public extension IteratorProtocol {
    func erase() -> AnyIterator<Element> {
        .init(self)
    }
}
