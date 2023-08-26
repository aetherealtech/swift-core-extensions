import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func eraseErrorType() -> Publishers.MapError<Self, any Error> {
        mapError { error in error as Error }
    }
}
