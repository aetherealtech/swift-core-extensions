import Assertions
import CollectionExtensions
import XCTest

@testable import DateExtensions

final class DateTests: XCTestCase {
    func testDateStrideThrough() throws {
        for _ in 0..<100 {
            let initialFireTime = Date()
            let latestFireTime = initialFireTime + 1000.0

            let interval = TimeInterval.random(in: 0..<10.0)

            let sequence = stride(
                from: initialFireTime,
                through: latestFireTime,
                by: interval
            )

            let fireTimes = Array(sequence)

            try assertEqual(fireTimes[0], initialFireTime)

            for fireTime in fireTimes {
                try assertTrue(fireTime <= latestFireTime)
            }

            for index in 0..<(fireTimes.count - 1) {

                let fireTime = fireTimes[index]
                let nextFireTime = fireTimes[index + 1]

                try assertEqual(
                    nextFireTime.timeIntervalSince(fireTime),
                    interval,
                    accuracy: 0.001
                )
            }

            try assertTrue(latestFireTime.timeIntervalSince(fireTimes.last!) < interval)
        }
    }
    
    func testDateStrideCount() throws {
        for _ in 0..<100 {
            let initialFireTime = Date()
            let count = 20

            let interval = TimeInterval.random(in: 0..<10.0)

            let sequence = stride(
                from: initialFireTime,
                by: interval,
                count: 20
            )

            let fireTimes = Array(sequence)

            try assertEqual(fireTimes.count, count)
            try assertEqual(fireTimes[0], initialFireTime)

            for index in 0..<(fireTimes.count - 1) {

                let fireTime = fireTimes[index]
                let nextFireTime = fireTimes[index + 1]

                try assertEqual(
                    nextFireTime.timeIntervalSince(fireTime),
                    interval,
                    accuracy: 0.001
                )
            }
        }
    }
}
