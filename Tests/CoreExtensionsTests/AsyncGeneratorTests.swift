import XCTest

@testable import CoreExtensions

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
final class AsyncGeneratorTests: XCTestCase {

    func testAsyncSequence() async throws {

        let squareSequence = AsyncGenerators.sequence({ i -> Int in

            try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))

            return i*i
        })

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

        for try await value in squareSequence {

            actualValues.append(value)

            if actualValues.count == expectedValues.count {
                break
            }
        }

        XCTAssertEqual(actualValues, expectedValues)
    }
}