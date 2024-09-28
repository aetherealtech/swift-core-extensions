public protocol DuplicateCompare<Element> {
    associatedtype Element
    
    func callAsFunction(_ lhs: Element, _ rhs: Element) -> Bool
}

public struct NonSendableDuplicateCompare<Element>: DuplicateCompare {
    public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Bool {
        _closure(lhs, rhs)
    }
    
    let _closure: (Element, Element) -> Bool
}

public struct SendableDuplicateCompare<Element>: DuplicateCompare, Sendable {
    public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Bool {
        _closure(lhs, rhs)
    }
    
    let _closure: @Sendable (Element, Element) -> Bool
}

public struct RemoveDuplicatesSequence<
    Source: Sequence,
    Compare: DuplicateCompare<Source.Element>
>: LazySequenceProtocol {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Source.Element? {
            while let next = source.next() {
                if !checked.contains(where: { checking in compare(next, checking) }) {
                    checked.append(next)
                    return next
                }
            }
            
            return nil
        }
        
        var source: Source.Iterator
        var compare: Compare
        var checked: [Element] = []
    }
    
    public func makeIterator() -> Iterator {
        .init(
            source: source.makeIterator(),
            compare: compare
        )
    }
    
    let source: Source
    var compare: Compare
}

extension RemoveDuplicatesSequence: Sendable where Source: Sendable, Compare: Sendable {}
