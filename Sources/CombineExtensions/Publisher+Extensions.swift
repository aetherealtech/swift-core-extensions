import Combine

// Opaque type crashes compiler, particularly when used in flatMapAsync

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func compact<O>() -> Publishers.CompactMap<Self, O> where Output == O? {
        compactMap { $0 }
    }
    
    func flatten<InnerOutput>() -> Publishers.FlatMap<Self.Output, Self> where Output: Publisher, Output.Output == InnerOutput, Output.Failure == Failure {
        flatMap { $0 }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func of<T>(type _: T.Type) -> Publishers.CompactMap<Self, T> {
        compactMap { element in element as? T }
    }
}
