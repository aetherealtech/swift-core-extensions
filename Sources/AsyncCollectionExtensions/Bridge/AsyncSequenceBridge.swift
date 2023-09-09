// Crash compiler: https://github.com/apple/swift/issues/67861

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncFunction<Result> {
    private let call: () async -> Result

    public init(call: @escaping () async -> Result) {
        self.call = call
    }

    public func callAsFunction() async -> Result {
        await call()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncSequenceBridge<Source: Sequence, Element>: AsyncSequence where Source.Element == AsyncFunction<Element> {
    public struct Iterator: AsyncIteratorProtocol {
        public mutating func next() async -> Element? {
            await source.next()?()
        }

        var source: Source.Iterator
    }

    public func makeAsyncIterator() -> Iterator {
        .init(source: source.makeIterator())
    }

    let source: Source
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Sequence {
    func await<R>() -> AsyncSequenceBridge<LazyMapSequence<LazySequence<Self>.Elements, AsyncFunction<R>>, R> where Element == () async -> R {
        .init(source: lazy.map(AsyncFunction.init))
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncThrowingFunction<Result> {
    private let call: () async throws -> Result
    
    public init(call: @escaping () async throws -> Result) {
        self.call = call
    }
    
    public func callAsFunction() async throws -> Result {
        try await call()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncThrowingSequenceBridge<Source: Sequence, Element>: AsyncSequence where Source.Element == AsyncThrowingFunction<Element> {
    public struct Iterator: AsyncIteratorProtocol {
        public mutating func next() async throws -> Element? {
            try await source.next()?()
        }

        var source: Source.Iterator
    }

    public func makeAsyncIterator() -> Iterator {
        .init(source: source.makeIterator())
    }

    let source: Source
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Sequence {
    func await<R>() -> AsyncThrowingSequenceBridge<LazyMapSequence<LazySequence<Self>.Elements, AsyncThrowingFunction<R>>, R> where Element == () async throws -> R {
        .init(source: lazy.map(AsyncThrowingFunction.init))
    }
}
