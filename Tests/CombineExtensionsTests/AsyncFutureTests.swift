import Assertions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class AsyncFutureTests: XCTestCase {
    @MainActor
    func testNoThrowFuture() async throws {
        let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
        
        var currentIndex = 0
        
        let work = { @Sendable @MainActor in
            let index = currentIndex
            
            currentIndex += 1
            
            await withCheckedContinuation { continuation in
                continuations.value[index] = continuation
            }
            
            return index
        }
        
        var receivedValues: [Int: Int] = [:]
        nonisolated(unsafe) let completions = CurrentValueSubject<[Int: Subscribers.Completion<Never>], Never>([:])
        
        let future = AsyncFuture(work)
                
        let subscription1 = future.sink(
            receiveCompletion: { @Sendable completion in
                Task { @MainActor in
                    completions.value[0] = completion
                }
            },
            receiveValue: { @Sendable value in
                Task { @MainActor in
                    receivedValues[0] = value
                }
            }
        )
        
        let continuation1 = await continuations.values
            .compactMap { $0[0] }
            .waitUntilNotNil()!
        
        let subscription2 = future.sink(
            receiveCompletion: { @Sendable completion in
                Task { @MainActor in
                    completions.value[1] = completion
                }
            },
            receiveValue: { @Sendable value in
                Task { @MainActor in
                    receivedValues[1] = value
                }
            }
        )
        
        let continuation2 = await continuations.values
            .compactMap { $0[1] }
            .waitUntilNotNil()!
        
        let subscription3 = future.sink(
            receiveCompletion: { @Sendable completion in
                Task { @MainActor in
                    completions.value[2] = completion
                }
            },
            receiveValue: { @Sendable value in
                Task { @MainActor in
                    receivedValues[2] = value
                }
            }
        )
        
        let continuation3 = await continuations.values
            .compactMap { $0[2] }
            .waitUntilNotNil()!
        
        continuation3.resume()

        let completion3 = await completions.values
            .compactMap { $0[2] }
            .waitUntilNotNil()!
        
        try assertEqual([2: 2], receivedValues)
        
        continuation2.resume()
        
        let completion2 = await completions.values
            .compactMap { $0[1] }
            .waitUntilNotNil()!
        
        try assertEqual([1: 1, 2: 2], receivedValues)
        
        continuation1.resume()
        
        let completion1 = await completions.values
            .compactMap { $0[0] }
            .waitUntilNotNil()!
        
        try assertEqual([0: 0, 1: 1, 2: 2], receivedValues)
        
        withExtendedLifetime(subscription1) { }
        withExtendedLifetime(subscription2) { }
        withExtendedLifetime(subscription3) { }
    }
}
