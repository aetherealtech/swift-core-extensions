@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncEnumeratedSequence<Source: AsyncSequence>: AsyncSequence {
    public typealias Element = (offset: Int, element: Source.Element)
     
    public struct AsyncIterator: AsyncIteratorProtocol {
        public mutating func next() async rethrows -> Element? {
            defer { index += 1 }
            return try await source.next().map { next in (index, next) }
        }
        
        var source: Source.AsyncIterator
        var index = 0
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        .init(
            source: source.makeAsyncIterator()
        )
    }
    
    let source: Source
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncEnumeratedSequence: Sendable where Source: Sendable {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    func enumerated() -> AsyncEnumeratedSequence<Self> {
        .init(source: self)
    }
}
