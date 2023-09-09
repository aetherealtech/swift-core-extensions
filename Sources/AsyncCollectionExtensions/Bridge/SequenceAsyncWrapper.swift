@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct SequenceAsyncWrapper<Source: Sequence>: AsyncSequence {
    public typealias Element = Source.Element
    
    public struct Iterator: AsyncIteratorProtocol {
        public mutating func next() async -> Element? {
            source.next()
        }

        var source: Source.Iterator
    }

    public func makeAsyncIterator() -> Iterator {
        .init(source: source.makeIterator())
    }

    let source: Source
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence {
    var async: SequenceAsyncWrapper<Self> {
        .init(source: self)
    }
}
