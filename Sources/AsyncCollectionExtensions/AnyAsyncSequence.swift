@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnyAsyncIterator<Element, Failure: Error>: AsyncIteratorProtocol {
    public mutating func next() async throws -> Element? {
        try await next_imp(&base)
    }
    
    public mutating func next(isolation actor: isolated (any Actor)?) async throws(Failure) -> Element? {
        try await nextIsolation_imp(&base, actor)
    }

    public private(set) var base: any AsyncIteratorProtocol
        
    init<Erasing: AsyncIteratorProtocol>(erasing: Erasing) where Erasing.Element == Element {
        base = erasing
        
        next_imp = { erased in
            var iterator = erased as! Erasing
            defer { erased = iterator }
            
            return try await iterator.next()
        }
        
        nextIsolation_imp = { _, _ in fatalError("Not supported on this platform") }
    }
    
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    init<Erasing: AsyncIteratorProtocol>(erasing: Erasing) where Erasing.Element == Element, Erasing.Failure == Failure {
        base = erasing
        
        next_imp = { erased in
            var iterator = erased as! Erasing
            defer { erased = iterator }
            
            return try await iterator.next()
        }
        
        nextIsolation_imp = { erased, actor throws(Failure) in
            var iterator = erased as! Erasing
            defer { erased = iterator }
            
            return try await iterator.next(isolation: actor)
        }
    }
    
    private let next_imp: (inout any AsyncIteratorProtocol) async throws -> Element?
    private let nextIsolation_imp: (inout any AsyncIteratorProtocol, isolated (any Actor)?) async throws(Failure) -> Element?
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncIteratorProtocol {
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    func erase() -> AnyAsyncIterator<Element, Failure> {
        .init(erasing: self)
    }
    
    @available(macOS, obsoleted: 15.0)
    @available(iOS, obsoleted: 18.0)
    @available(tvOS, obsoleted: 18.0)
    @available(watchOS, obsoleted: 11.0)
    func erase() -> AnyAsyncIterator<Element, any Error> {
        .init(erasing: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AnyAsyncSequence<Element, Failure: Error>: AsyncSequence {
    public typealias AsyncIterator = AnyAsyncIterator<Element, Failure>
    
    public private(set) var base: any AsyncSequence

    public func makeAsyncIterator() -> AsyncIterator {
        makeAsyncIterator_imp(base)
    }
    
    @available(macOS, obsoleted: 15.0)
    @available(iOS, obsoleted: 18.0)
    @available(tvOS, obsoleted: 18.0)
    @available(watchOS, obsoleted: 11.0)
    init<Erasing: AsyncSequence>(erasing: Erasing) where Erasing.Element == Element, Failure == any Error {
        base = erasing
        
        makeAsyncIterator_imp = { erased in
            (erased as! Erasing).makeAsyncIterator().erase()
        }
    }
    
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    init<Erasing: AsyncSequence>(erasing: Erasing) where Erasing.Element == Element, Erasing.Failure == Failure {
        base = erasing
        
        makeAsyncIterator_imp = { erased in
            (erased as! Erasing).makeAsyncIterator().erase()
        }
    }
    
    private let makeAsyncIterator_imp: (any AsyncSequence) -> AsyncIterator
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncSequence {
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    func erase() -> AnyAsyncSequence<Element, Failure> {
        .init(erasing: self)
    }
    
    @available(macOS, obsoleted: 15.0)
    @available(iOS, obsoleted: 18.0)
    @available(tvOS, obsoleted: 18.0)
    @available(watchOS, obsoleted: 11.0)
    func erase() -> AnyAsyncSequence<Element, any Error> {
        .init(erasing: self)
    }
}
