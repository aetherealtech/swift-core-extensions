import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class PublisherExtensionsTests: XCTestCase {
    @MainActor
    func testFlatten() async throws {
        let publisher = (0..<10)
            .publisher
            .map { index in
                (0..<10).map { index * 10 + $0 }.publisher
            }
            .flatten()
      
        var receivedValues: [Int] = []
        
        let subscription = publisher
            .sink { value in
                receivedValues.append(value)
            }
        
        let expectedValues = Array(0..<100)
        
        try assertEqual(expectedValues, receivedValues)
        
        withExtendedLifetime(subscription) {}
    }
    
    @MainActor
    func testWaitForNext() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitForNext()
                }
            }
                        
            try assertNil(value.value)
            
            let expectedValue = Int.random(in: 0..<100)
            
            publisher.send(expectedValue)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertEqual(expectedValue, value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitForNextCompletes() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int??, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitForNext()
                }
            }
                        
            try assertEqual(nil as Int??, value.value)
                        
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertNil(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntil() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntil { $0 >= 50 }
                }
            }
            
            let expectedValue = Int.random(in: 50..<100)
            
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertNil(value.value)
            
            publisher.send(expectedValue)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertEqual(expectedValue, value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilCompletes() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int??, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntil { $0 >= 50 }
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertEqual(nil as Int??, value.value)
            
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertNil(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilAsync() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntil { value async in value >= 50 }
                }
            }
            
            let expectedValue = Int.random(in: 50..<100)
            
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertNil(value.value)
            
            publisher.send(expectedValue)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertEqual(expectedValue, value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilAsyncCompletes() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int??, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntil { value async in value >= 50 }
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertEqual(nil as Int??, value.value)
            
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertNil(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilNotNil() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int?, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntilNotNil()
                }
            }
            
            let expectedValue = Int.random(in: 0..<100)
            
            for _ in 0..<20 {
                publisher.send(nil)
            }
            
            try assertNil(value.value)
            
            publisher.send(expectedValue)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertEqual(expectedValue, value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilNotNilCompletes() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int?, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int??, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntilNotNil()
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(nil)
            }
            
            try assertEqual(nil as Int??, value.value)
            
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertNil(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilNilTrue() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int?, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Bool?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntilNil()
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try await Task.sleep(timeInterval: 0.1)
            
            try assertNil(value.value)
            
            publisher.send(nil)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertTrue(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilNilFalse() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int?, Never>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Bool?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntilNil()
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try await Task.sleep(timeInterval: 0.1)
            
            try assertNil(value.value)
            
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertFalse(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitFor() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, Never>()
            
            nonisolated(unsafe) let result = CurrentValueSubject<Bool?, Never>(nil)

            let value = Int.random(in: 50..<100)
            
            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    result.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).wait(for: value)
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertNil(result.value)
            
            publisher.send(value)
            
            for await value in result.values {
                guard let value else {
                    continue
                }
                
                try assertTrue(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitForCompletes() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, Never>()
            
            nonisolated(unsafe) let result = CurrentValueSubject<Bool?, Never>(nil)

            let value = Int.random(in: 50..<100)
            
            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    result.value = await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).wait(for: value)
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertNil(result.value)
            
            publisher.send(completion: .finished)
            
            for await value in result.values {
                guard let value else {
                    continue
                }
                
                try assertFalse(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitForNextThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitForNext()
                }
            }
                        
            try assertNil(value.value)
            
            let expectedValue = Int.random(in: 0..<100)
            
            publisher.send(expectedValue)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertEqual(expectedValue, value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitForNextCompletesThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int??, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitForNext()
                }
            }
                        
            try assertEqual(nil as Int??, value.value)
                        
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertNil(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntil { $0 >= 50 }
                }
            }
            
            let expectedValue = Int.random(in: 50..<100)
            
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertNil(value.value)
            
            publisher.send(expectedValue)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertEqual(expectedValue, value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilCompletesThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int??, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntil { $0 >= 50 }
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertEqual(nil as Int??, value.value)
            
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertNil(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilAsyncThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntil { value async in value >= 50 }
                }
            }
            
            let expectedValue = Int.random(in: 50..<100)
            
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertNil(value.value)
            
            publisher.send(expectedValue)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertEqual(expectedValue, value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilAsyncCompletesThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int??, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntil { value async in value >= 50 }
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertEqual(nil as Int??, value.value)
            
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertNil(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilNotNilThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int?, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntilNotNil()
                }
            }
            
            let expectedValue = Int.random(in: 0..<100)
            
            for _ in 0..<20 {
                publisher.send(nil)
            }
            
            try assertNil(value.value)
            
            publisher.send(expectedValue)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertEqual(expectedValue, value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilNotNilCompletesThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int?, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Int??, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntilNotNil()
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(nil)
            }
            
            try assertEqual(nil as Int??, value.value)
            
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertNil(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilNilTrueThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int?, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Bool?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntilNil()
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try await Task.sleep(timeInterval: 0.1)
            
            try assertNil(value.value)
            
            publisher.send(nil)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertTrue(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitUntilNilFalseThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int?, TestError>()
            
            nonisolated(unsafe) let value = CurrentValueSubject<Bool?, Never>(nil)

            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    value.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).waitUntilNil()
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try await Task.sleep(timeInterval: 0.1)
            
            try assertNil(value.value)
            
            publisher.send(completion: .finished)
            
            for await value in value.values {
                guard let value else {
                    continue
                }
                
                try assertFalse(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitForThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, TestError>()
            
            nonisolated(unsafe) let result = CurrentValueSubject<Bool?, Never>(nil)

            let value = Int.random(in: 50..<100)
            
            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    result.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).wait(for: value)
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertNil(result.value)
            
            publisher.send(value)
            
            for await value in result.values {
                guard let value else {
                    continue
                }
                
                try assertTrue(value)
                break
            }
        }
    }
    
    @MainActor
    func testWaitForCompletesThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let publisher = PassthroughSubject<Int, TestError>()
            
            nonisolated(unsafe) let result = CurrentValueSubject<Bool?, Never>(nil)

            let value = Int.random(in: 50..<100)
            
            await withCheckedContinuation { continuation in
                let publisher = publisher
                    .handleEvents(receiveSubscription: { @Sendable _ in Task { @MainActor in
                        continuation.resume()
                    } })
                
                Task {
                    result.value = try await publisher.buffer(size: .max, prefetch: .keepFull, whenFull: .dropOldest).wait(for: value)
                }
            }
                        
            for _ in 0..<20 {
                publisher.send(.random(in: 0..<50))
            }
            
            try assertNil(result.value)
            
            publisher.send(completion: .finished)
            
            for await value in result.values {
                guard let value else {
                    continue
                }
                
                try assertFalse(value)
                break
            }
        }
    }
    
}
