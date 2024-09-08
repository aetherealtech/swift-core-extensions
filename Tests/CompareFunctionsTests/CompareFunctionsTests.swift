import Assertions
import XCTest

@testable import CompareFunctions

final class CompareFunctionsTests: XCTestCase {
    struct TestStruct {
        struct InnerStruct {
            let intMember: Int
            let floatMember: Double
            
            static var random: Self {
                .init(
                    intMember: .random(in: -10..<10),
                    floatMember: .random(in: -1e6..<1e6)
                )
            }
        }
        
        let intMember: Int
        let floatMember: Double
        let stringMember: String
        let innerMember: InnerStruct
        
        static var random: Self {
            .init(
                intMember: .random(in: -10..<10),
                floatMember: .random(in: -1e6..<1e6),
                stringMember: UUID().uuidString,
                innerMember: .random
            )
        }
    }
    
    func testComparisonResult() async throws {
        let values = Array(0..<100)
        
        for first in values {
            for second in values {
                let resultStatic: ComparisonResult = Int.compare(lhs: first, rhs: second)
                let resultMember: ComparisonResult = first.compare(to: second)
                
                try assertEqual(resultMember, resultStatic)
                
                if first < second {
                    try assertEqual(.orderedAscending, resultStatic)
                } else if first > second {
                    try assertEqual(.orderedDescending, resultStatic)
                } else {
                    try assertEqual(.orderedSame, resultStatic)
                }
            }
        }
    }
    
    func testCompareByTransformUsing() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
            
            let result = compare(
                first,
                second,
                by: { $0.innerMember },
                using: { $0.intMember.compare(to: $1.intMember) }
            )
                        
            try assertEqual(first.innerMember.intMember.compare(to: second.innerMember.intMember), result)
            
            let sameResult = compare(
                first,
                first,
                by: { $0.innerMember },
                using: { $0.intMember.compare(to: $1.intMember) }
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByKeyPathUsing() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
            
            let keyPath = \TestStruct.innerMember
            
            let result = compare(
                first,
                second,
                by: keyPath,
                using: { $0.intMember.compare(to: $1.intMember) }
            )
            
            try assertEqual(first.innerMember.intMember.compare(to: second.innerMember.intMember), result)
            
            let sameResult = compare(
                first,
                first,
                by: { $0.innerMember },
                using: { $0.intMember.compare(to: $1.intMember) }
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByTransform() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
            
            let result = compare(
                first,
                second,
                by: { $0.intMember }
            )
            
            try assertEqual(first.intMember.compare(to: second.intMember), result)
            
            let sameResult = compare(
                first,
                first,
                by: { $0.intMember }
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByKeyPath() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
            
            let keyPath = \TestStruct.intMember
            
            let result = compare(
                first,
                second,
                by: keyPath
            )
            
            try assertEqual(first.intMember.compare(to: second.intMember), result)
            
            let sameResult = compare(
                first,
                first,
                by: keyPath
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareUsingComparesVariadic() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let result = compare(
                first,
                second,
                using: { $0.intMember.compare(to: $1.intMember) }, { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = compare(
                first,
                first,
                using: { $0.intMember.compare(to: $1.intMember) }, { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareUsingComparesVariadicThrows() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let firstCompare: (TestStruct, TestStruct) throws -> ComparisonResult = {
                $0.intMember.compare(to: $1.intMember)
            }
            
            let secondCompare: (TestStruct, TestStruct) throws -> ComparisonResult = {
                $0.innerMember.intMember.compare(to: $1.innerMember.intMember)
            }
            
            let result = try compare(
                first,
                second,
                using: firstCompare, secondCompare
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = try compare(
                first,
                first,
                using: firstCompare, secondCompare
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareUsingComparesArray() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let compares: [(TestStruct, TestStruct) -> ComparisonResult] = [
                { $0.intMember.compare(to: $1.intMember) },
                { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
            ]
            
            let result = compare(
                first,
                second,
                using: compares
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = compare(
                first,
                first,
                using: compares
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareUsingComparesArrayThrows() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let compares: [(TestStruct, TestStruct) throws -> ComparisonResult] = [
                { $0.intMember.compare(to: $1.intMember) },
                { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
            ]
            
            let result = try compare(
                first,
                second,
                using: compares
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = try compare(
                first,
                first,
                using: compares
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByTransformsVariadic() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let result = compare(
                first,
                second,
                by: { $0.intMember}, { $0.innerMember.intMember }
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = compare(
                first,
                first,
                by: { $0.intMember }, { $0.innerMember.intMember }
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByTransformsVariadicThrows() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let firstTransform: (TestStruct) throws -> Int = \.intMember
            let secondTransform: (TestStruct) throws -> Int = \.innerMember.intMember
            
            let result = try tryCompare(
                first,
                second,
                by: firstTransform, secondTransform
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = try tryCompare(
                first,
                first,
                by: firstTransform, secondTransform
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByTransformsArray() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let transforms: [(TestStruct) -> Int] = [
                { $0.intMember },
                { $0.innerMember.intMember }
            ]
            
            let result = compare(
                first,
                second,
                by: transforms
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = compare(
                first,
                first,
                by: transforms
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByTransformsArrayThrows() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let transforms: [(TestStruct) throws -> Int] = [
                { $0.intMember },
                { $0.innerMember.intMember }
            ]
            
            let result = try compare(
                first,
                second,
                by: transforms
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = try compare(
                first,
                first,
                by: transforms
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByKeyPathsVariadic() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let keyPath1 = \TestStruct.intMember
            let keyPath2 = \TestStruct.innerMember.intMember
            
            let result = compare(
                first,
                second,
                by: keyPath1, keyPath2
            )
            
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = compare(
                first,
                first,
                by: keyPath1, keyPath2
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
    
    func testCompareByKeyPathsArray() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
            
            let keyPaths: [KeyPath<TestStruct, Int>] = [
                \.intMember,
                \.innerMember.intMember
            ]
            
            let result = compare(
                first,
                second,
                by: keyPaths
            )
        
            let expectedResult = first.intMember == second.intMember ?
                first.innerMember.intMember.compare(to: second.innerMember.intMember) :
                first.intMember.compare(to: second.intMember)
            
            try assertEqual(expectedResult, result)
            
            let sameResult = compare(
                first,
                first,
                by: keyPaths
            )
            
            try assertEqual(.orderedSame, sameResult)
        }
    }
}
