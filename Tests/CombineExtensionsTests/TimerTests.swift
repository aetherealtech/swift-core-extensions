import Assertions
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class TimerTests: XCTestCase {
    func testTimer() async throws {
        let timer = DispatchQueue.global().timer(
            interval: .milliseconds(2000)
        )
                
        let subscription1 = timer.sink { print("Received 1") }
        
        try await Task.sleep(timeInterval: 0.5)
        
        let subscription2 = timer.sink { print("Received 2") }
        
        try await Task.sleep(timeInterval: 0.5)
        
        let subscription3 = timer.sink { print("Received 3") }
        
        try await Task.sleep(timeInterval: 0.5)
        
        try await Task.sleep(timeInterval: 10)
        
        subscription2.cancel()
        
        try await Task.sleep(timeInterval: 10)
        
        withExtendedLifetime(subscription1) { }
        withExtendedLifetime(subscription2) { }
        withExtendedLifetime(subscription3) { }
    }
}
