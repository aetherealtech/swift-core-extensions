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

final class DestructiveSequence<Element>: Sequence, IteratorProtocol {
    func next() -> Element? {
        return iterator.next()
    }
    
    func makeIterator() -> Iterator {
        self
    }
    
    init(array: [Element]) {
        iterator = array.makeIterator()
    }
    
    private var iterator: [Element].Iterator
}

struct TestError: Error, Equatable {}
