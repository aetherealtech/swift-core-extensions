import Stubbing

@Stubbable
struct TestStruct: Equatable {
    @Stubbable
    struct InnerStruct: Equatable {
        var intMember: Int
        var floatMember: Double
    }
    
    var intMember: Int
    var floatMember: Double
    var stringMember: String
    var innerMember: InnerStruct
}

struct DestructiveSequence<Element>: Sequence, IteratorProtocol {
    mutating func next() -> Element? {
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
