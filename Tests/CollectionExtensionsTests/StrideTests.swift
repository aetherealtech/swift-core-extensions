import Assertions
import XCTest

@testable import CollectionExtensions

final class StrideTests: XCTestCase {
    func testStrideWithCount() throws {
        for _ in 0..<100 {
            let initial = Double.random(in: 0.0..<10000.0)

            let interval = Double.random(in: 0..<10.0)
            let count = Int.random(in: 15..<25)

            let sequence = stride(
                from: initial,
                by: interval,
                count: count
            )

            let collectedValues = Array(sequence)

            try assertEqual(collectedValues[0], initial)
            try assertEqual(collectedValues.count, count)

            for index in 0..<(collectedValues.count - 1) {
                let currentValue = collectedValues[index]
                let nextValue = collectedValues[index + 1]

                try assertEqual(nextValue - currentValue, interval, accuracy: 0.001)
            }
        }
    }
    
    protocol FloatAccuracy<T> {
        associatedtype T: FloatingPoint
        
        static var accuracy: T { get }
    }
    
    enum ToOneThousandth: FloatAccuracy { static var accuracy: Double { 0.001 } }
    
    struct Approximation<Accuracy: FloatAccuracy>: Equatable {
        typealias T = Accuracy.T
        
        var value: T
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            abs(lhs.value - rhs.value) < Accuracy.accuracy
        }
    }
    
    typealias ApproximationToOneThousandth = Approximation<ToOneThousandth>
    
    func testStrideRegularIntervalsUntil() throws {
        for _ in 0..<100 {
            let initial = Double.random(in: 0.0..<1000.0)

            let interval = Double.random(in: 0..<10.0)
            let until = Double.random(in: 2000.0..<5000.0)

            let sequence = Double.regularIntervals(
                startingAt: initial,
                interval,
                until: until
            )
    
            let collectedValues = sequence
                .map(ApproximationToOneThousandth.init)

            var expectedResults: [ApproximationToOneThousandth] = []
            
            var current = initial
            
            while current < until {
                expectedResults.append(.init(value: current))
                current += interval
            }
            
            try assertEqual(expectedResults, collectedValues)
        }
    }
    
    func testStrideRegularIntervalsCount() throws {
        for _ in 0..<100 {
            let initial = Double.random(in: 0.0..<10000.0)

            let interval = Double.random(in: 0..<10.0)
            let count = Int.random(in: 15..<25)

            let sequence = Double.regularIntervals(
                startingAt: initial,
                interval,
                count: count
            )

            let collectedValues = Array(sequence)

            try assertEqual(collectedValues[0], initial)
            try assertEqual(collectedValues.count, count)

            for index in 0..<(collectedValues.count - 1) {
                let currentValue = collectedValues[index]
                let nextValue = collectedValues[index + 1]

                try assertEqual(nextValue - currentValue, interval, accuracy: 0.001)
            }
        }
    }
}
