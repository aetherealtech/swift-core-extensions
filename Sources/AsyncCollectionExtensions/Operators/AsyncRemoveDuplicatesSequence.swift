
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncRemoveDuplicatesSequence<Source: AsyncSequence>: AsyncSequence {
    public typealias Element = Source.Element
     
    public struct AsyncIterator: AsyncIteratorProtocol {
        public mutating func next() async rethrows -> Element? {
            guard let next = try await source.next(), !found.contains(next, by: compare) else {
                return nil
            }
            
            found.append(next)
            
            return next
        }
        
        var source: Source.AsyncIterator
        let compare: (Element, Element) -> Bool
        var found: [Element] = []
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        .init(
            source: source.makeAsyncIterator(),
            compare: compare
        )
    }
    
    let source: Source
    let compare: @Sendable (Element, Element) -> Bool
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncRemoveDuplicatesSequence: Sendable where Source: Sendable {}
