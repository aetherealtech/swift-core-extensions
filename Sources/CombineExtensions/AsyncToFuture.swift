import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Future where Failure == Never {
    convenience init(
        executing function: @escaping @Sendable () async -> Output
    ) {
        self.init { promise in
            Task {
                await promise(.success(function()))
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Future where Failure == Error {
    convenience init(
        executing function: @escaping @Sendable () async throws -> Output
    ) {
        self.init { promise in
            Task {
                do {
                    try await promise(.success(function()))

                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
