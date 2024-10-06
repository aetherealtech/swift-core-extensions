import AsyncCollectionExtensions
import Combine
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func compact<O>() -> Publishers.CompactMap<Self, O> where Output == O? {
        compactMap { $0 }
    }
    
    func flatten<InnerOutput>() -> Publishers.FlatMap<Output, Self> where Output: Publisher, Output.Output == InnerOutput, Output.Failure == Failure {
        flatMap { $0 }
    }
}

@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
public extension Publisher where Output: Publisher {
    func flatten() -> Publishers.FlatMap<Output, Publishers.SetFailureType<Self, Output.Failure>> where Failure == Never {
        flatMap { $0 }
    }
    
    func flatten() -> Publishers.FlatMap<Output, Self> where Failure == Never, Output.Failure == Never {
        flatMap { $0 }
    }
    
    func flatten() -> Publishers.FlatMap<Publishers.SetFailureType<Output, Self.Failure>, Self> where Output.Failure == Never {
        flatMap { $0 }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher {
    @discardableResult
    func waitForNext() async throws -> Output? {
        try await values.next()
    }
    
    @discardableResult
    func waitUntil(_ condition: @Sendable (Output) throws -> Bool) async throws -> Output? {
        try await values.waitUntil(condition)
    }
    
    @discardableResult
    func waitUntil(_ condition: @Sendable (Output) async throws -> Bool) async throws -> Output? {
        try await values.waitUntil(condition)
    }
    
    @discardableResult
    func waitUntilNotNil<Wrapped>() async throws -> Wrapped? where Output == Wrapped? {
        try await values.waitUntilNotNil()
    }
    
    @discardableResult
    func waitUntilNil<Wrapped>() async throws -> Bool where Output == Wrapped? {
        try await values.waitUntilNil()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Output: Equatable & Sendable {
    func wait(for value: Output) async throws {
        try await values.wait(for: value)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Failure == Never {
    @discardableResult
    func waitForNext() async -> Output? {
        await values.next()
    }
    
    @discardableResult
    func waitUntil(_ condition: @Sendable (Output) throws -> Bool) async rethrows -> Output? {
        try await values.waitUntil(condition)
    }
    
    @discardableResult
    func waitUntil(_ condition: @Sendable (Output) async throws -> Bool) async rethrows -> Output? {
        try await values.waitUntil(condition)
    }
    
    @discardableResult
    func waitUntilNotNil<Wrapped>() async -> Wrapped? where Output == Wrapped? {
        await values.waitUntilNotNil()
    }
    
    @discardableResult
    func waitUntilNil<Wrapped>() async -> Bool where Output == Wrapped? {
        await values.waitUntilNil()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension Publisher where Output: Equatable & Sendable, Failure == Never {
    func wait(for value: Output) async {
        await values.waitUntil { $0 == value }
        
        // This requires a try, not sure why (hey that rhymes)
//        await values.wait(for: value)
    }
}
