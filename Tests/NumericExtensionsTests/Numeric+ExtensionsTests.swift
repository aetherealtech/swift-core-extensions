import Assertions
import CollectionExtensions
import XCTest

@testable import NumericExtensions

final class NumericExtensionsTests: XCTestCase {
    func testApproximately() throws {
        try testApproximately(
            generator: { Float.random(in: -10000 ..< 10000) },
            tolerances: [ 1e-6, 1e-3, 1e0, 1e3 ]
        )
        
        try testApproximately(
            generator: { Double.random(in: -10000 ..< 10000) },
            tolerances: [ 1e-6, 1e-3, 1e0, 1e3 ]
        )
    }
    
    func testApproximatelyOptional() throws {
        try testApproximatelyOptional(
            generator: { Float.random(in: -10000 ..< 10000) },
            tolerances: [ 1e-6, 1e-3, 1e0, 1e3 ]
        )
        
        try testApproximatelyOptional(
            generator: { Double.random(in: -10000 ..< 10000) },
            tolerances: [ 1e-6, 1e-3, 1e0, 1e3 ]
        )
    }
    
    private func testApproximately<T: Numeric>(
        generator: () -> T,
        tolerances: some Collection<T.Magnitude>
    ) throws {
        for _ in 0..<100 {
            let first = generator()
            let second = generator()
            
            let distance = (first - second).magnitude
            
            for tolerance in tolerances {
                let result = first.isApproximately(second, tolerance: tolerance)
                let expectedResult = distance <= tolerance
                
                try assertEqual(result, expectedResult)
            }
        }
    }
    
    private func testApproximatelyOptional<T: Numeric>(
        generator: () -> T,
        tolerances: some Collection<T.Magnitude>
    ) throws {
        for _ in 0..<100 {
            let first = Bool.random() ? generator() : nil
            let second = Bool.random() ? generator() : nil
            
            let distance: T.Magnitude? = if let first, let second { (first - second).magnitude } else { nil }
            
            for tolerance in tolerances {
                let result = first.isApproximately(second, tolerance: tolerance)
                let expectedResult = if let distance { distance <= tolerance } else { false }
                
                try assertEqual(result, expectedResult)
            }
        }
    }
}
