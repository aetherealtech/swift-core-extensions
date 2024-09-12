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
    
            let collectedValues = Array(sequence)

            var expectedResults: [Double] = []
            
            var current = initial
            
            while current < until {
                expectedResults.append(current)
                current += interval
            }
            
            try assertTrue(expectedResults.elementsEqual(collectedValues, by: { abs($0 - $1) < 0.001 }))
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
