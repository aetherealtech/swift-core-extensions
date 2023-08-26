import Combine

// WARNING - This is not covered by unit tests and may suffer from subtle bugs.
// If you want to use it in production code, you should add thorough test cases first (including making sure a stream's completion is always received *after* all the mapped values are received)
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    func mapAsync<NewOutput>(
        _ transform: @escaping (Output) async -> NewOutput
    ) -> some Publisher<NewOutput, Failure> {
        map { value in { await transform(value) } }
            .await()
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Error {
    func mapAsync<NewOutput>(
        _ transform: @escaping (Output) async throws -> NewOutput
    ) -> some Publisher<NewOutput, Error> {
        map { value in { try await transform(value) } }
            .await()
    }
}
