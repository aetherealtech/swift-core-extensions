import CoreExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncAccumulateSequence<Source: AsyncSequence, Result>: AsyncSequence {
    public typealias Element = Result
     
    public struct AsyncIterator: AsyncIteratorProtocol {
        public mutating func next() async rethrows -> Result? {
            guard let next = try await source.next() else {
                return nil
            }
            
            current = await accumulator(current, next)
            
            return current
        }
        
        init(
            source: Source.AsyncIterator,
            initial: Result,
            accumulator: @escaping (Result, Source.Element) async -> Result
        ) {
            self.source = source
            self.current = initial
            self.accumulator = accumulator
        }
        
        private var source: Source.AsyncIterator
        private var current: Result
        private let accumulator: (Result, Source.Element) async -> Result
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        .init(
            source: source.makeAsyncIterator(),
            initial: initial,
            accumulator: accumulator
        )
    }
    
    let source: Source
    let initial: Result
    let accumulator: @Sendable (Result, Source.Element) async -> Result
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension AsyncAccumulateSequence: Sendable where Source: Sendable, Result: Sendable {}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    func accumulate<R>(_ initialValue: R, _ accumulate: @escaping @Sendable (R, Element) -> R) async throws -> AsyncAccumulateSequence<Self, R> {
        .init(
            source: self,
            initial: initialValue,
            accumulator: accumulate
        )
    }
}
