import XCTest

@testable import CollectionExtensions

final class StrideTests: XCTestCase {

    func testStrideWithcount() {

        for _ in 0..<100 {

            let initial = Double.random(in: 0.0..<10000.0)

            let interval = Double.random(in: 0..<10.0)
            let count = Int.random(in: 15..<25)

            let sequence = stride(from: initial, by: interval, count: count)

            let collectedValues = Array(sequence)

            XCTAssertEqual(collectedValues[0], initial)

            if(collectedValues.count != count) {
                print("TEST")
            }

            XCTAssertEqual(collectedValues.count, count)

            for index in 0..<(collectedValues.count - 1) {

                let currentValue = collectedValues[index]
                let nextValue = collectedValues[index + 1]

                XCTAssertEqual(nextValue - currentValue, interval, accuracy: 0.001)
            }
        }
    }
}
