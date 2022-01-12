import XCTest

@testable import CoreExtensions

final class DateTests: XCTestCase {

    func testDateStride() {

        for _ in 0..<100 {

            let initialFireTime = Date()
            let latestFireTime = initialFireTime + 1000.0

            let interval = TimeInterval.random(in: 0..<10.0)

            let sequence = stride(from: initialFireTime, through: latestFireTime, by: interval)

            let fireTimes = Array(sequence)

            XCTAssertEqual(fireTimes[0], initialFireTime)

            for fireTime in fireTimes {
                XCTAssertTrue(fireTime <= latestFireTime)
            }

            for index in 0..<(fireTimes.count - 1) {

                let fireTime = fireTimes[index]
                let nextFireTime = fireTimes[index + 1]

                XCTAssertEqual(nextFireTime.timeIntervalSince(fireTime), interval, accuracy: 0.001)
            }

            XCTAssertTrue(latestFireTime.timeIntervalSince(fireTimes.last!) < interval)
        }
    }
}
