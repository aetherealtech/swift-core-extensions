public protocol Accumulator<Element, Result> {
    associatedtype Element
    associatedtype Result
    
    func callAsFunction(_ current: Result, _ next: Element) -> Result
}

public struct NonSendableAcculuator<Element, Result>: Accumulator {
    public func callAsFunction(_ current: Result, _ next: Element) -> Result {
        _closure(current, next)
    }
    
    let _closure: (Result, Element) -> Result
}

public struct SendableAcculuator<Element, Result>: Accumulator, Sendable {
    public func callAsFunction(_ current: Result, _ next: Element) -> Result {
        _closure(current, next)
    }
    
    let _closure: @Sendable (Result, Element) -> Result
}

public struct LazyAccumulateSequence<
    Source: Sequence,
    Acc: Accumulator
>: LazySequenceProtocol where Acc.Element == Source.Element {
    public typealias Element = Acc.Result
    
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Element? {
            guard let current else {
                return nil
            }
                        
            self.current = source.next().map { next in accumulator(current, next) }
            
            return current
        }
        
        var source: Source.Iterator
        var current: Element?
        let accumulator: Acc
    }
    
    public func makeIterator() -> Iterator {
        .init(
            source: source.makeIterator(),
            current: initial,
            accumulator: accumulator
        )
    }
    
    let source: Source
    let initial: Element
    let accumulator: Acc
}

extension LazyAccumulateSequence: Sendable where Source: Sendable, Element: Sendable, Acc: Sendable {}
