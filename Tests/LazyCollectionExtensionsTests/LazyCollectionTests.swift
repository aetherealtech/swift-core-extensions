import Assertions
import XCTest

@testable import LazyCollectionExtensions

struct NonMutableCollection<Base: MutableCollection>: Collection {
    typealias Element = Base.Element
    typealias Index = Base.Index
    typealias Iterator = Base.Iterator
    
    func makeIterator() -> Base.Iterator {
        base.makeIterator()
    }
    
    var startIndex: Index { base.startIndex }
    var endIndex: Index { base.endIndex }
    
    func index(after i: Base.Index) -> Base.Index { base.index(after: i) }
    
    subscript(position: Base.Index) -> Base.Element {
        _read { yield base[position] }
    }
    
    let base: Base
}

extension MutableCollection {
    var nonMutable: NonMutableCollection<Self> { .init(base: self) }
}

final class LazyCollectionTests: XCTestCase {
    func testIndices() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]
        
        let expectedResult = [
            3,
            2,
            5
        ]
        
        let result = testArray
            .lazy[[1, 2, 4]]
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testIndicesSubscript() throws {
        let testArray = [
            1,
            2,
            4,
            5,
            6,
            9,
        ].nonMutable
            
        let result = testArray
            .lazy[[1, 2, 4]]
        
        try assertEqual(4, result[1])
    }
    
    func testIndicesCollection() throws {
        let testArray = [
            1,
            2,
            4,
            5,
            6,
            9,
        ]
            
        var result = testArray
            .lazy[[1, 2, 4]]
        
        try assertEqual(0, result.startIndex)
        try assertEqual(3, result.endIndex)
        
        try assertEqual(2, result.index(after: 1))
        
        try assertEqual(testArray[1], result[0])
        try assertEqual(testArray[2], result[1])
        try assertEqual(testArray[4], result[2])
        
        try assertEqual(0, result.index(before: 1))
        
        try assertEqual(2, result.index(0, offsetBy: 2))
        try assertEqual(1, result.index(0, offsetBy: 1, limitedBy: 2))
        try assertEqual(nil, result.index(0, offsetBy: 5, limitedBy: 2))
        
        try assertEqual(4, result[1])
        
        result[1] = 15
        
        try assertEqual(15, result.source[2])
    }
}
