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
            
            let resultPartial = Compare.by(
                { $0.innerMember },
                using: { $0.intMember.compare(to: $1.intMember) }
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
            
            let resultPartial = Compare.by(
                keyPath,
                using: { $0.intMember.compare(to: $1.intMember) }
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
            
            let resultPartial = Compare.by(
                { $0.intMember }
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
            
            let resultPartial = Compare.by(
                keyPath
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
            
            let resultPartial = Compare.using(
                { $0.intMember.compare(to: $1.intMember) },
                { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
    
    func testCompareUsingComparesArray() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let compares: [CompareFunction<TestStruct>] = [
                { $0.intMember.compare(to: $1.intMember) },
                { $0.innerMember.intMember.compare(to: $1.innerMember.intMember) }
            ]
            
            let result = compare(
                first,
                second,
                using: compares
            )
            
            let resultPartial = Compare.using(
                compares
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
    
    func testCompareByTransformsVariadic() async throws {
        for _ in 0..<100 {
            let first = TestStruct.random
            let second = TestStruct.random
                        
            let result = compare(
                first,
                second,
                by: { $0.intMember}, { $0.innerMember.intMember }
            )
            
            let resultPartial = Compare.by(
                { $0.intMember },
                { $0.innerMember.intMember }
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
            
            let resultPartial = Compare.by(
                transforms
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
            
            let resultPartial = Compare.by(
                keyPath1,
                keyPath2
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
            
            let resultPartial = Compare.by(
                keyPaths
            )(first, second)
            
            try assertEqual(resultPartial, result)
            
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
