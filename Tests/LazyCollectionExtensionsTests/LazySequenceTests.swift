import Assertions
import XCTest

@testable import LazyCollectionExtensions

enum SomeEnum {
    case thisCase
    case thatCase
}

final class LazySequenceTests: XCTestCase {
    func testCompact() throws {
        let testSequence = DestructiveSequence([
            1,
            2,
            nil,
            4,
            5,
            6,
            nil,
            nil,
            9,
            nil
        ])
        
        let expectedResult = [
            1,
            2,
            4,
            5,
            6,
            9
        ]
        
        let result = testSequence
            .lazy
            .compact()
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testFlatten() throws {
        let testSequence = DestructiveSequence([
            DestructiveSequence([1, 2, 3]),
            DestructiveSequence([4, 5, 6]),
            DestructiveSequence([7, 8, 9]),
            DestructiveSequence([10, 11, 12])
        ])
        
        let expectedResult = Array(1...12)
        
        let result = testSequence
            .lazy
            .flatten()
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testAppending() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let result = testSequence
            .lazy
            .appending(9)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testAppendingIfTrue() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let result = testSequence
            .lazy
            .appending(9, if: true)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testAppendingIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]

        let testSequence = DestructiveSequence(testArray)
        
        let result = testSequence
            .lazy
            .appending(9, if: false)
        
        try assertEqual(testArray, Array(result))
    }
    
    func testAppendingSequence() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9,
            4,
            11,
            7
        ]
        
        let result = testSequence
            .lazy
            .appending(contentsOf: [9, 4, 11, 7])
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testAppendingSequenceIfTrue() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9,
            1,
            11,
            7
        ]
        
        let result = testSequence
            .lazy
            .appending(contentsOf: [9, 1, 11, 7], if: true)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testAppendingSequenceIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]

        let testSequence = DestructiveSequence(testArray)
        
        let result = testSequence
            .lazy
            .appending(contentsOf: [9, 1, 11, 7], if: false)
        
        try assertEqual(testArray, Array(result))
    }
    
    func testPrepending() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            9,
            1,
            3,
            2,
            8,
            5,
        ]
        
        let result = testSequence
            .lazy
            .prepending(9)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testPrependingIfTrue() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            9,
            1,
            3,
            2,
            8,
            5,
        ]
        
        let result = testSequence
            .lazy
            .prepending(9, if: true)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testPrependingIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]

        let testSequence = DestructiveSequence(testArray)
        
        let result = testSequence
            .lazy
            .prepending(9, if: false)
        
        try assertEqual(testArray, Array(result))
    }
    
    func testPrependingSequence() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            9,
            4,
            11,
            7,
            1,
            3,
            2,
            8,
            5
        ]
        
        let result = testSequence
            .lazy
            .prepending(contentsOf: [9, 4, 11, 7])
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testPrependingSequenceIfTrue() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            9,
            1,
            11,
            7,
            1,
            3,
            2,
            8,
            5,
        ]
        
        let result = testSequence
            .lazy
            .prepending(contentsOf: [9, 1, 11, 7], if: true)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testPrependingSequenceIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]

        let testSequence = DestructiveSequence(testArray)
        
        let result = testSequence
            .lazy
            .prepending(contentsOf: [9, 1, 11, 7], if: false)
        
        try assertEqual(testArray, Array(result))
    }
    
    func testInserting() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            9,
            8,
            5,
        ]
        
        let result = testSequence
            .lazy
            .inserting(9, at: 3)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testInsertingIfTrue() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            9,
            8,
            5,
        ]
        
        let result = testSequence
            .lazy
            .inserting(9, at: 3, if: true)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testInsertingIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]

        let testSequence = DestructiveSequence(testArray)
        
        let result = testSequence
            .lazy
            .inserting(9, at: 3, if: false)
        
        try assertEqual(testArray, Array(result))
    }
    
    func testInsertingSequence() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            9,
            4,
            11,
            7,
            8,
            5,
        ]
        
        let result = testSequence
            .lazy
            .inserting(contentsOf: [9, 4, 11, 7], at: 3)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testInsertingSequenceIfTrue() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            9,
            1,
            11,
            7,
            8,
            5,
        ]
        
        let result = testSequence
            .lazy
            .inserting(contentsOf: [9, 1, 11, 7], at: 3, if: true)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testInsertingSequenceIfFalse() throws {
        let testArray = [
            1,
            3,
            2,
            8,
            5
        ]

        let testSequence = DestructiveSequence(testArray)
        
        let result = testSequence
            .lazy
            .inserting(contentsOf: [9, 1, 11, 7], at: 3, if: false)
        
        try assertEqual(testArray, Array(result))
    }
    
    func testFilterIndices() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            2,
            5
        ]
        
        let result = testSequence
            .lazy
            .filterIndices { $0.isMultiple(of: 2) }
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRemovingAtIndex() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            5
        ]
        
        let result = testSequence
            .lazy
            .removing(at: 3)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRemovingWhereIndices() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            3,
            8
        ]
        
        let result = testSequence
            .lazy
            .removingWhereIndices { $0.isMultiple(of: 2) }
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRemovingAtIndices() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            8,
            5
        ]
        
        let result = testSequence
            .lazy
            .removing(at: DestructiveSequence([1, 2]))
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRemovingAllWhere() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            1,
            3,
            5
        ]
        
        let result = testSequence
            .lazy
            .removingAll { $0.isMultiple(of: 2) }
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRemovingAllOfBy() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        let result = testSequence
            .lazy
            .removingAll(of: TestStruct.stub(intMember: 3), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, Array(result))
    }

    func testRemovingAllOfSequenceBy() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[2],
            testArray[3],
            testArray[4]
        ]
        
        let values = [
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9)
        ]

        let result = testSequence
            .lazy
            .removingAll(of: DestructiveSequence(values), by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRemovingDuplicatesBy() throws {
        let testArray = [
            TestStruct.stub(intMember: 1),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 2),
            TestStruct.stub(intMember: 8),
            TestStruct.stub(intMember: 5),
            TestStruct.stub(intMember: 3),
            TestStruct.stub(intMember: 9),
            TestStruct.stub(intMember: 3),
        ]
        
        let testSequence = DestructiveSequence(testArray)
        
        let expectedResult = [
            testArray[0],
            testArray[1],
            testArray[2],
            testArray[3],
            testArray[4],
            testArray[6]
        ]
        
        let result = testSequence
            .lazy
            .removingDuplicates(by: { $0.intMember == $1.intMember })
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testLast() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = 5
        
        let result = testSequence
            .lazy
            .last
        
        try assertEqual(expectedResult, result)
    }
    
    func testCount() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = 5
        
        let result = testSequence
            .lazy
            .count()
        
        try assertEqual(expectedResult, result)
    }
    
    func testContainsAtLeastTrue() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
                
        let result = testSequence
            .lazy
            .contains(atLeast: 4)
        
        try assertTrue(result)
    }
    
    func testContainsAtLeastFalse() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
                
        let result = testSequence
            .lazy
            .contains(atLeast: 6)
        
        try assertFalse(result)
    }
    
    func testAccumulate() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5
        ])
        
        let expectedResult = [
            10,
            11,
            14,
            16,
            24,
            29
        ]
                
        let result = testSequence
            .lazy
            .accumulate(10, { $0 + $1 })
        
        try assertEqual(expectedResult, Array(result))
    }

    func testCartesianProduct() async throws {
        let firstSource = [0, 1, 2, 3]
        let secondSource = ["A", "B", "C"]
        let thirdSource = [SomeEnum.thisCase, SomeEnum.thatCase]
        let fourthSource = [1.1, 1.2, 1.3]
        
        var first: DestructiveSequence<[Int]> { .init(firstSource) }
        var second: DestructiveSequence<[String]> { .init(secondSource) }
        var third: DestructiveSequence<[SomeEnum]> { .init(thirdSource) }
        var fourth: DestructiveSequence<[Double]> { .init(fourthSource) }
   
        let result1 = Array(LazySequences.cartesianProduct(first, second, third))
        let result2 = Array(LazySequences.cartesianProduct(first, second, third, fourth))
        
        let result1Member = Array(first.lazy.cartesianProduct(with: second, third))
        let result2Member = Array(first.lazy.cartesianProduct(with: second, third, fourth))

        var index = 0

        for x in 0..<firstSource.count {
            for y in 0..<secondSource.count {
                for z in 0..<thirdSource.count {
                    let result = result1[index]
                    try assertEqual(result.0, firstSource[x])
                    try assertEqual(result.1, secondSource[y])
                    try assertEqual(result.2, thirdSource[z])
                    
                    let resultMember = result1Member[index]
                    try assertEqual(resultMember.0, firstSource[x])
                    try assertEqual(resultMember.1, secondSource[y])
                    try assertEqual(resultMember.2, thirdSource[z])
                    
                    index += 1
                }
            }
        }
        
        index = 0
        
        for x in 0..<firstSource.count {
            for y in 0..<secondSource.count {
                for z in 0..<thirdSource.count {
                    for w in 0..<fourthSource.count {
                        let result = result2[index]
                        try assertEqual(result.0, firstSource[x])
                        try assertEqual(result.1, secondSource[y])
                        try assertEqual(result.2, thirdSource[z])
                        try assertEqual(result.3, fourthSource[w])
                        
                        let resultMember = result2Member[index]
                        try assertEqual(resultMember.0, firstSource[x])
                        try assertEqual(resultMember.1, secondSource[y])
                        try assertEqual(resultMember.2, thirdSource[z])
                        try assertEqual(resultMember.3, fourthSource[w])
                        
                        index += 1
                    }
                }
            }
        }
    }
    
    func testRemovingAllOf() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ])
 
        let expectedResult = [
            1,
            2,
            8,
            5,
            9
        ]
        
        let result = testSequence
            .lazy
            .removingAll(of: 3)
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRemovingAllOfSequence() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ])
 
        let expectedResult = [
            1,
            2,
            8,
            5
        ]
        
        let result = testSequence
            .lazy
            .removingAll(of: DestructiveSequence([3, 9]))
        
        try assertEqual(expectedResult, Array(result))
    }
    
    func testRemovingDuplicates() throws {
        let testSequence = DestructiveSequence([
            1,
            3,
            2,
            8,
            5,
            3,
            9,
            3
        ])
        
        let expectedResult = [
            1,
            3,
            2,
            8,
            5,
            9
        ]
        
        let result = testSequence
            .lazy
            .removingDuplicates()
        
        let finalResult = Array(result)
        
        try assertEqual(expectedResult, finalResult)
    }
    
    func testCartesianProductCollection() async throws {
        let first = [0, 1, 2, 3]
        let second = ["A", "B", "C"]
        let third = [SomeEnum.thisCase, SomeEnum.thatCase]
        let fourth = [1.1, 1.2, 1.3]

        let result1 = Array(LazySequences.cartesianProduct(first, second, third))
        let result2 = Array(LazySequences.cartesianProduct(first, second, third, fourth))

        let result1Member = Array(first.lazy.cartesianProduct(with: second, third))
        let result2Member = Array(first.lazy.cartesianProduct(with: second, third, fourth))

        var index = 0

        for x in 0..<first.count {
            for y in 0..<second.count {
                for z in 0..<third.count {
                    let result = result1[index]
                    try assertEqual(result.0, first[x])
                    try assertEqual(result.1, second[y])
                    try assertEqual(result.2, third[z])
                    
                    let resultMember = result1Member[index]
                    try assertEqual(resultMember.0, first[x])
                    try assertEqual(resultMember.1, second[y])
                    try assertEqual(resultMember.2, third[z])
                    
                    index += 1
                }
            }
        }
        
        index = 0
        
        for x in 0..<first.count {
            for y in 0..<second.count {
                for z in 0..<third.count {
                    for w in 0..<fourth.count {
                        let result = result2[index]
                        try assertEqual(result.0, first[x])
                        try assertEqual(result.1, second[y])
                        try assertEqual(result.2, third[z])
                        try assertEqual(result.3, fourth[w])
                        
                        let resultMember = result2Member[index]
                        try assertEqual(resultMember.0, first[x])
                        try assertEqual(resultMember.1, second[y])
                        try assertEqual(resultMember.2, third[z])
                        try assertEqual(resultMember.3, fourth[w])
                        
                        index += 1
                    }
                }
            }
        }
    }
    
    func testCartesianProductEmpty() throws {
        let result = LazySequences.cartesianProduct()
        
        try assertTrue(result.count() == 0)
    }
    
    func testZip() throws {
        let firstSource = [0, 1, 2, 3]
        let secondSource = ["A", "B", "C"]
        let thirdSource = [SomeEnum.thisCase, SomeEnum.thatCase]
        let fourthSource = [1.1, 1.2, 1.3]
        
        var first: DestructiveSequence<[Int]> { .init(firstSource) }
        var second: DestructiveSequence<[String]> { .init(secondSource) }
        var third: DestructiveSequence<[SomeEnum]> { .init(thirdSource) }
        var fourth: DestructiveSequence<[Double]> { .init(fourthSource) }
 
        let result1 = Array(LazySequences.zip(first, second, third))
        let result2 = Array(LazySequences.zip(first, second, third, fourth))
        
        let result1Member = Array(first.lazy.zip(with: second, third))
        let result2Member = Array(first.lazy.zip(with: second, third, fourth))
  
        for index in 0..<2 {
            let result = result1[index]
            try assertEqual(result.0, firstSource[index])
            try assertEqual(result.1, secondSource[index])
            try assertEqual(result.2, thirdSource[index])
            
            let resultMember = result1Member[index]
            try assertEqual(resultMember.0, firstSource[index])
            try assertEqual(resultMember.1, secondSource[index])
            try assertEqual(resultMember.2, thirdSource[index])
        }
        
        for index in 0..<2 {
            let result = result2[index]
            try assertEqual(result.0, firstSource[index])
            try assertEqual(result.1, secondSource[index])
            try assertEqual(result.2, thirdSource[index])
            try assertEqual(result.3, fourthSource[index])
            
            let resultMember = result2Member[index]
            try assertEqual(resultMember.0, firstSource[index])
            try assertEqual(resultMember.1, secondSource[index])
            try assertEqual(resultMember.2, thirdSource[index])
            try assertEqual(resultMember.3, fourthSource[index])
        }
    }
    
    func testZipEmpty() throws {
        let result = LazySequences.zip()
        
        try assertTrue(result.count() == 0)
    }
}
