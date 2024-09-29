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

final class DestructiveSequence<Base: Sequence>: AsyncSequence, AsyncIteratorProtocol {
    func next() async -> Base.Element? {
        iterator.next()
    }
    
    func makeAsyncIterator() -> DestructiveSequence {
        self
    }
    
    init(_ base: Base) {
        iterator = base.makeIterator()
    }
    
    private var iterator: Base.Iterator
}

final class SyncDestructiveSequence<Base: Sequence>: Sequence, IteratorProtocol {
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
