import Assertions
import CollectionExtensions
import XCTest

@testable import NumericExtensions

final class DecimalExtensionsTests: XCTestCase {
    func testIntValue() throws {
        for _ in 0..<100 {
            let int = Int.random(in: -1000..<1000)
            let decimal = Decimal(int)

            try assertEqual(decimal.intValue, int)
        }
    }
    
    func testFloatValue() throws {
        for _ in 0..<100 {
            let float = Float.random(in: -1000..<1000)
            let decimal = Decimal(Double(float))

            try assertEqual(decimal.floatValue, float)
        }
    }
    
    func testDoubleValue() throws {
        for _ in 0..<100 {
            let double = Double.random(in: -1000..<1000)
            let decimal = Decimal(double)

            try assertTrue((decimal.doubleValue - double).magnitude <= 1e12)
        }
    }
    
    func testStringValue() throws {
        let generateDigit: () -> Character = { Int.random(in: 0...9).description.first! }
        
        for _ in 0..<100 {
            let string = (String((0..<5).map { _ in generateDigit() }) + "." + (0..<5).map { _ in generateDigit() })
                .trimmingCharacters(in: ["0"])
            
            let decimal = Decimal(string: string)!

            try assertEqual(decimal.stringValue, string)
        }
    }
    
    func testRandom() throws {
        for _ in 0..<100 {
            let lowerBound = Decimal(Double.random(in: -10000 ..< -100))
            let upperBound = Decimal(Double.random(in: 100 ..< 10000))
            
            for _ in 0..<100 {
                let result = Decimal.random(in: lowerBound ..< upperBound)
                try assertTrue(result >= lowerBound && result <= upperBound)
            }
        }
    }
}
