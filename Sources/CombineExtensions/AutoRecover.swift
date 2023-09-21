import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func autoRecover<P: Publisher>(publisher: @escaping () -> P) -> AnyPublisher<P.Output, Never> {
    publisher()
        .catch { _ in autoRecover(publisher: publisher) }
        .eraseToAnyPublisher()
}
