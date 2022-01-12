import XCTest

@testable import CoreExtensions

final class GeneratorTests: XCTestCase {

    func testSequence() throws {

        let squareSequence = Generators.sequence({ i in i*i })

        let expectedValues = [
            0,
            1,
            4,
            9,
            16,
            25,
            36,
            49,
            64,
            81,
            100
        ]

        var actualValues = [Int]()

        for value in squareSequence {

            actualValues.append(value)

            if actualValues.count == expectedValues.count {
                break
            }
        }

        XCTAssertEqual(actualValues, expectedValues)
    }

    func testFibonacciSequence() throws {
        
        let fibonacciSequence = Generators.fibonacciSequence()

        let expectedValues = [
            1,
            2,
            3,
            5,
            8,
            13,
            21,
            34,
            55,
            89,
            144,
            233,
            377,
            610,
            987,
            1597,
            2584,
            4181,
            6765,
            10946,
            17711,
            28657
        ]

        var actualValues = [Int]()

        for value in fibonacciSequence {

            actualValues.append(value)

            if actualValues.count == expectedValues.count {
                break
            }
        }

        XCTAssertEqual(actualValues, expectedValues)
    }
}
