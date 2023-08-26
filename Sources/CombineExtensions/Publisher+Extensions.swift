import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func compact<O>() -> some Publisher<O, Failure> where Output == O? {
        compactMap { $0 }
    }
    
    func flatten<InnerOutput>() -> some Publisher<InnerOutput, Failure> where Output: Publisher, Output.Output == InnerOutput, Output.Failure == Failure {
        flatMap { $0 }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func of<T>(type _: T.Type) -> some Publisher<T, Failure> {
        compactMap { element in element as? T }
    }
}
