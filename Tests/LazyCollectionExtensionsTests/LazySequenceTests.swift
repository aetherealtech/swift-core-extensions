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
