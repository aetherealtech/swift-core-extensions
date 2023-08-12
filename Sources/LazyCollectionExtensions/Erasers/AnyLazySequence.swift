public struct AnyLazySequence<Element>: LazySequenceProtocol {
    public typealias Iterator = AnyIterator<Element>
    
    public func makeIterator() -> AnyIterator<Element> {
        makeIteratorImp()
    }
    
    init<Base: LazySequenceProtocol>(_ base: Base) where Base.Element == Element {
        makeIteratorImp = { .init(base.makeIterator()) }
    }
    
    private let makeIteratorImp: () -> Iterator
}

public extension LazySequenceProtocol {
    func lazyErase() -> AnyLazySequence<Element> {
        .init(self)
    }
}
