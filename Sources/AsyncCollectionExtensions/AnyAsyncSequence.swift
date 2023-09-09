@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnyAsyncIterator<Element>: AsyncIteratorProtocol {
    public mutating func next() async throws -> Element? {
        try await next_imp(&base)
    }
    
    public private(set) var base: any AsyncIteratorProtocol
    
    init<Erasing: AsyncIteratorProtocol>(erasing: Erasing) where Erasing.Element == Element {
        base = erasing
        
        next_imp = { erased in
            var iterator = erased as! Erasing
            defer { erased = iterator }
            
            return try await iterator.next()
        }
    }
    
    private let next_imp: (inout any AsyncIteratorProtocol) async throws -> Element?
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncIteratorProtocol {
    func erase() -> AnyAsyncIterator<Element> {
        .init(erasing: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnyAsyncSequence<Element>: AsyncSequence {
    public typealias AsyncIterator = AnyAsyncIterator<Element>
    
    public private(set) var base: any AsyncSequence

    public func makeAsyncIterator() -> AsyncIterator {
        makeAsyncIterator_imp(base)
    }
    
    init<Erasing: AsyncSequence>(erasing: Erasing) where Erasing.Element == Element {
        base = erasing
        
        makeAsyncIterator_imp = { erased in
            (erased as! Erasing).makeAsyncIterator().erase()
        }
    }
    
    private let makeAsyncIterator_imp: (any AsyncSequence) -> AsyncIterator
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncSequence {
    func erase() -> AnyAsyncSequence<Element> {
        .init(erasing: self)
    }
}
