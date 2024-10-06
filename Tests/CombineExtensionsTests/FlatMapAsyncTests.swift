import Assertions
import AsyncExtensions
import Combine
import XCTest

@testable import CombineExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class FlatMapAsyncTests: XCTestCase {
    @MainActor
    func testFlatMapAsyncNoThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
 
            let publisher = (0..<10).publisher
                .flatMapAsync { @MainActor index in
                    await withCheckedContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }
                        .publisher
                }
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for innerIndex in 0..<10 {
                    for try await receivedValues in receivedValues.values {
                        if receivedValues.contains(index * 10 + innerIndex) {
                            break
                        }
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testFlatMapAsyncNoThrowsInnerPublisherThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
 
            let publisher = (0..<10).publisher
                .flatMapAsync { @MainActor index in
                    await withCheckedContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }
                        .publisher
                        .setFailureType(to: TestError.self)
                }
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for innerIndex in 0..<10 {
                    for try await receivedValues in receivedValues.values {
                        if receivedValues.contains(index * 10 + innerIndex) {
                            break
                        }
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testFlatMapAsyncOuterThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
            
            let publisher = (0..<10).publisher
                .setFailureType(to: TestError.self)
                .flatMapAsync { @MainActor index in
                    await withCheckedContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }.publisher
                }
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for innerIndex in 0..<10 {
                    for try await receivedValues in receivedValues.values {
                        if receivedValues.contains(index * 10 + innerIndex) {
                            break
                        }
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testFlatMapAsyncOuterThrowsInnerPublisherThrowsMatchingError() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, Never>], Never>([:])
            
            let publisher = (0..<10).publisher
                .setFailureType(to: TestError.self)
                .flatMapAsync { @MainActor index in
                    await withCheckedContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }
                        .publisher
                        .setFailureType(to: TestError.self)
                }
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for innerIndex in 0..<10 {
                    for try await receivedValues in receivedValues.values {
                        if receivedValues.contains(index * 10 + innerIndex) {
                            break
                        }
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }

    @MainActor
    func testFlatMapAsyncThrowingNoThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
            
            let publisher = (0..<10).publisher
                .flatMapAsync { @MainActor index in
                    try await withCheckedThrowingContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }
                        .publisher
                }
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for innerIndex in 0..<10 {
                    for try await receivedValues in receivedValues.values {
                        if receivedValues.contains(index * 10 + innerIndex) {
                            break
                        }
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testFlatMapAsyncThrowingThrows() async throws {
        try await withTimeout(timeInterval: 5.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
            
            let publisher = (0..<10).publisher
                .flatMapAsync { @MainActor index in
                    try await withCheckedThrowingContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }.publisher
                }
            
            nonisolated(unsafe) let receivedCompletion = CurrentValueSubject<Subscribers.Completion<any Error>?, Never>(nil)
            
            let subscription = publisher
                .sink { @Sendable completion in
                    Task { @MainActor in
                        receivedCompletion.value = completion
                    }
                } receiveValue: { @Sendable _ in }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                if index == 5 {
                    allContinuations[index]!.resume(throwing: TestError())
                } else {
                    allContinuations[index]!.resume()
                }
            }
            
            for try await receivedCompletion in receivedCompletion.values {
                if let receivedCompletion {
                    guard case let .failure(error) = receivedCompletion else {
                        throw Fail("Expected publisher to fail")
                    }
                    
                    try assertTrue(error is TestError)
                    
                    break
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testFlatMapAsyncThrowingInnerPublisherThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
            
            let publisher = (0..<10).publisher
                .flatMapAsync { @MainActor index in
                    try await withCheckedThrowingContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }
                        .publisher
                        .setFailureType(to: TestError.self)
                }
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for innerIndex in 0..<10 {
                    for try await receivedValues in receivedValues.values {
                        if receivedValues.contains(index * 10 + innerIndex) {
                            break
                        }
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }

    @MainActor
    func testFlatMapAsyncOuterAndInnerThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
            
            let publisher = (0..<10).publisher
                .setFailureType(to: TestError.self)
                .flatMapAsync { @MainActor index in
                    try await withCheckedThrowingContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }
                        .publisher
                }
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for innerIndex in 0..<10 {
                    for try await receivedValues in receivedValues.values {
                        if receivedValues.contains(index * 10 + innerIndex) {
                            break
                        }
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
    @MainActor
    func testFlatMapAsyncOuterAndInnerAndInnerPublisherThrows() async throws {
        try await withTimeout(timeInterval: 1.0) {
            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
            
            let publisher = (0..<10).publisher
                .setFailureType(to: TestError.self)
                .flatMapAsync { @MainActor index in
                    try await withCheckedThrowingContinuation { continuation in
                        continuations.value[index] = continuation
                    }
                    
                    return (0..<10).map { index * 10 + $0 }
                        .publisher
                        .setFailureType(to: TestError.self)
                }
            
            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
            
            let subscription = publisher
                .sink { @Sendable _ in
                    
                } receiveValue: { @Sendable value in
                    Task { @MainActor in
                        receivedValues.value.insert(value)
                    }
                }
            
            for await continuations in continuations.values {
                if continuations.count == 10 {
                    break
                }
            }
            
            let allContinuations = continuations.value
            
            for index in (0..<10).reversed() {
                allContinuations[index]!.resume()
                
                for innerIndex in 0..<10 {
                    for try await receivedValues in receivedValues.values {
                        if receivedValues.contains(index * 10 + innerIndex) {
                            break
                        }
                    }
                }
            }
            
            withExtendedLifetime(subscription) {}
            
            // If it gets through this without timing out, the test should pass
        }
    }
    
//    @MainActor
//    func testFlatMapAsyncOuterAndInnerUntypedThrows() async throws {
//        try await withTimeout(timeInterval: 1.0) {
//            let continuations = CurrentValueSubject<[Int: CheckedContinuation<Void, any Error>], Never>([:])
//            
//            let publisher = (0..<10).publisher
//                .setFailureType(to: (any Error).self)
//                .flatMapAsync { @MainActor index in
//                    try await withCheckedThrowingContinuation { continuation in
//                        continuations.value[index] = continuation
//                    }
//                    
//                    return (0..<10).map { index * 10 + $0 }.publisher
//                }
//            
//            nonisolated(unsafe) let receivedValues = CurrentValueSubject<Set<Int>, Never>([])
//            
//            let subscription = publisher
//                .sink { @Sendable _ in
//                    
//                } receiveValue: { @Sendable value in
//                    Task { @MainActor in
//                        receivedValues.value.insert(value)
//                    }
//                }
//            
//            for await continuations in continuations.values {
//                if continuations.count == 10 {
//                    break
//                }
//            }
//            
//            let allContinuations = continuations.value
//            
//            for index in (0..<10).reversed() {
//                allContinuations[index]!.resume()
//                
//                for innerIndex in 0..<10 {
//                    for try await receivedValues in receivedValues.values {
//                        if receivedValues.contains(index * 10 + innerIndex) {
//                            break
//                        }
//                    }
//                }
//            }
//            
//            withExtendedLifetime(subscription) {}
//            
//            // If it gets through this without timing out, the test should pass
//        }
//    }
}
