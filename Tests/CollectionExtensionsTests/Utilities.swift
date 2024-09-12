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

struct DestructiveSequence<Element>: Sequence {
    struct Iterator: IteratorProtocol {
        mutating func next() -> Element? {
            guard !array.isEmpty else {
                return nil
            }
            
            return array.removeFirst()
        }
        
        var array: [Element]
    }
    
    func makeIterator() -> Iterator {
        .init(array: array)
    }
    
    let array: [Element]
}
