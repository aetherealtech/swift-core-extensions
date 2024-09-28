import Stubbing

@Stubbable
struct TestStruct: Hashable {
    @Stubbable
    struct InnerStruct: Hashable {
        var intMember: Int
        var floatMember: Double
    }
    
    var intMember: Int
    var floatMember: Double
    var stringMember: String
    var innerMember: InnerStruct
}

final class DestructiveSequence<Base: Sequence>: Sequence, IteratorProtocol, @unchecked Sendable {
    func next() -> Base.Element? {
        return iterator.next()
    }
    
    func makeIterator() -> Iterator {
        self
    }
    
    init(_ base: Base) {
        iterator = base.makeIterator()
    }
    
    private var iterator: Base.Iterator
}
