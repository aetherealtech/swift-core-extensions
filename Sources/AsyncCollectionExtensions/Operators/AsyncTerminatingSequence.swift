@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncTerminatingSequence<Base: AsyncSequence>: AsyncSequence {
    public typealias Element = Base.Element
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        public mutating func next() async rethrows -> Base.Element? {
            guard let next = try await base.next(), !(await terminateCondition(next)) else {
                return nil
            }
            
            return next
        }
        
        var base: Base.AsyncIterator
        let terminateCondition: (Base.Element) async -> Bool
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        .init(
            base: base.makeAsyncIterator(),
            terminateCondition: terminateCondition
        )
    }
    
    let base: Base
    let terminateCondition: @Sendable (Base.Element) async -> Bool
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncTerminatingSequence: Sendable where Base: Sendable {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    func terminate(when condition: @escaping @Sendable (Element) async -> Bool) -> AsyncTerminatingSequence<Self> {
        .init(
            base: self,
            terminateCondition: condition
        )
    }
}
