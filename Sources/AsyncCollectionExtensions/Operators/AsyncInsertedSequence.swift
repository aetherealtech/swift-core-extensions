import CoreExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncLazyInsertedSequence<Source: AsyncSequence, Inserted: AsyncSequence>: AsyncSequence where Source.Element == Inserted.Element {
    public typealias Element = Source.Element
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        public mutating func next() async rethrows -> Source.Element? {
            if remainingUntilInsert == 0 {
                return try await inserted.next() ?? (try await source.next())
            } else {
                remainingUntilInsert -= 1
                return try await source.next()
            }
        }
        
        var source: Source.AsyncIterator
        var inserted: Inserted.AsyncIterator
        var remainingUntilInsert: Int
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        .init(
            source: source.makeAsyncIterator(),
            inserted: inserted.makeAsyncIterator(),
            remainingUntilInsert: insertAt
        )
    }
    
    let source: Source
    let inserted: Inserted
    let insertAt: Int
}
