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

        await completions.values
            .compactMap { $0[2] }
            .waitUntilNotNil()
        
        try assertEqual([2: 2], receivedValues)
        
        continuation2.resume()
        
        await completions.values
            .compactMap { $0[1] }
            .waitUntilNotNil()
        
        try assertEqual([1: 1, 2: 2], receivedValues)
        
        continuation1.resume()
        
        await completions.values
            .compactMap { $0[0] }
            .waitUntilNotNil()
        
        try assertEqual([0: 0, 1: 1, 2: 2], receivedValues)
        
        withExtendedLifetime(subscription1) { }
        withExtendedLifetime(subscription2) { }
        withExtendedLifetime(subscription3) { }
    }
    
    @MainActor
    func testThrowingFuture() async throws {
        let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
        
        var currentIndex = 0
        
        let work = { @Sendable @MainActor in
            let index = currentIndex
            
            currentIndex += 1
            
            try await withCheckedThrowingContinuation { continuation in
                continuations.value[index] = continuation
            }
            
            return index
        }
        
        var receivedValues: [Int: Int] = [:]
        nonisolated(unsafe) let completions = CurrentValueSubject<[Int: Subscribers.Completion<any Error>], Never>([:])
        
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
        
        guard case .finished = completion3 else {
            throw Fail("Expected a normal publisher completion")
        }
        
        continuation2.resume(throwing: TestError())
        
        let completion2 = await completions.values
            .compactMap { $0[1] }
            .waitUntilNotNil()!
        
        try assertEqual([2: 2], receivedValues)
        
        guard case let .failure(error) = completion2 else {
            throw Fail("Expected a publisher failure")
        }
        
        try assertTrue(error is TestError)
        
        continuation1.resume()
        
        let completion1 = await completions.values
            .compactMap { $0[0] }
            .waitUntilNotNil()!
        
        guard case .finished = completion1 else {
            throw Fail("Expected a normal publisher completion")
        }
        
        try assertEqual([0: 0, 2: 2], receivedValues)
        
        withExtendedLifetime(subscription1) { }
        withExtendedLifetime(subscription2) { }
        withExtendedLifetime(subscription3) { }
    }
    
    @MainActor
    func testFutureNoDemand() async throws {
        var run = false
        
        let future = AsyncFuture { @MainActor in
            run = true
        }
        
        let subscriber = future.subscribeNoDemand()
        
        try await Task.sleep(nanoseconds: 1_000)
        
        try assertFalse(run)
        try assertTrue(subscriber.received.isEmpty)
    }
    
    @MainActor
    func testFutureRepeatedDemand() async throws {
        var runCount = 0
        
        let future = AsyncFuture { @MainActor in
            runCount += 1
            
            return "Ran"
        }
        
        var values: [String] = []
        
        let subscriber = future
            .subscribeManualDemand { value in
                Task { @MainActor in values.append(value) }
            }
        
        subscriber.request(demand: .max(1))
        subscriber.request(demand: .max(1))
        
        try await Task.sleep(nanoseconds: 1_000_000)
        
        try assertEqual(["Ran"], values)
    }
    
    @MainActor
    func testFutureCancel() async throws {
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

        await completions.values
            .compactMap { $0[2] }
            .waitUntilNotNil()
        
        try assertEqual([2: 2], receivedValues)
        
        subscription2.cancel()
        
        continuation2.resume()
        
        try assertEqual([2: 2], receivedValues)
        
        continuation1.resume()
        
        await completions.values
            .compactMap { $0[0] }
            .waitUntilNotNil()
        
        try assertEqual([0: 0, 2: 2], receivedValues)
        
        withExtendedLifetime(subscription1) { }
        withExtendedLifetime(subscription2) { }
        withExtendedLifetime(subscription3) { }
    }
}
