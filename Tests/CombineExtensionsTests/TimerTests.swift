import Assertions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TimerTests: XCTestCase {
    @MainActor
    func testTimer() async throws {
        let timer = DispatchQueue.main.timer(
            interval: .milliseconds(20)
        )
        
        let times = CurrentValueSubject<[Date], Never>([])
                
        let subscription = timer.sink {
            times.value.append(.now)
        }
        
        for try await currentTimes in times.values {
            if currentTimes.count == 10 {
                break
            }
        }
                        
        let intervals = Array(times.value
            .indices)[1...]
            .map { index in
                times.value[index].timeIntervalSince(times.value[index - 1])
            }
        
        for interval in intervals {
            try assertEqual(0.02, interval, accuracy: 0.0075)
        }
        
        withExtendedLifetime(subscription) { }
    }
    
    @MainActor
    func testTimerNoDemand() async throws {
        let timer = DispatchQueue.main.timer(
            interval: .milliseconds(20)
        )
        
        let subscriber = timer.subscribeNoDemand()

        try await Task.sleep(nanoseconds: 1_000_000)
        
        try assertTrue(subscriber.received.isEmpty)
    }
    
    @MainActor
    func testTimerNoMoreDemand() async throws {
        let timer = DispatchQueue.main.timer(
            interval: .milliseconds(20)
        )
        
        var times: [Date] = []
        
        for await _ in timer.values {
            times.append(.now)
            
            if times.count == 10 {
                break
            }
        }

        let intervals = Array(times
            .indices)[1...]
            .map { index in
                times[index].timeIntervalSince(times[index - 1])
            }
        
        for interval in intervals {
            try assertEqual(0.02, interval, accuracy: 0.0075)
        }
    }
}
