public struct LazyIfElseSequence<
    If: Sequence,
    Else: Sequence<If.Element>
>: LazySequenceProtocol {
    public typealias Element = If.Element
    
    public enum Iterator: IteratorProtocol {
        case `if`(If.Iterator)
        case `else`(Else.Iterator)
        
        public mutating func next() -> Element? {
            switch self {
                case var .if(iterator):
                    guard let next = iterator.next() else { return nil }
                    self = .if(iterator)
                    return next
                    
                case var .else(iterator):
                    guard let next = iterator.next() else { return nil }
                    self = .else(iterator)
                    return next
            }
        }
    }
    
    public func makeIterator() -> Iterator {
        condition ? .if(`if`.makeIterator()) : .else(`else`.makeIterator())
    }
    
    let `if`: If
    let `else`: Else
    let condition: Bool
}

extension LazyIfElseSequence: Sendable where If: Sendable, Else: Sendable {}
