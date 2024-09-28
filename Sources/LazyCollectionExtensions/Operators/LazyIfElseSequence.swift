public enum LazyIfElseSequence<
    If: Sequence,
    Else: Sequence<If.Element>
>: LazySequenceProtocol {
    case `if`(If)
    case `else`(Else)
    
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
        switch self {
            case let .if(base): .if(base.makeIterator())
            case let .else(base): .else(base.makeIterator())
        }
    }
}
