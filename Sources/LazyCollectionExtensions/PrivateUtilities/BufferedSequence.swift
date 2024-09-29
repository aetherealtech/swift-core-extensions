final class BufferedSequence<Base: Sequence>: Sequence {
    struct Iterator: IteratorProtocol {
        mutating func next() -> Base.Element? {
            if index < sequence.buffer.count {
                let result = sequence.buffer[index]
                index += 1
                return result
            } else if let next = sequence.iterator.next() {
                sequence.buffer.append(next)
                index += 1
                return next
            } else {
                return nil
            }
        }
        
        let sequence: BufferedSequence
        var index = 0
    }
    
    init(base: Base) {
        iterator = base.makeIterator()
    }
    
    func makeIterator() -> Iterator {
        .init(sequence: self)
    }
    
    private var buffer: [Base.Element] = []
    private var iterator: Base.Iterator
}

extension Sequence {
    func buffered() -> AnySequence<Any> {
        if let collection = self as? any Collection {
            return collection.fullyErased()
        } else {
            return BufferedSequence(base: self).fullyErased()
        }
    }
}
