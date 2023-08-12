@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Collection {
    func awaitAll<R>(maxConcurrency: Int = .max) async -> [R] where Element == () async -> R {
        var results = [R?](repeating: nil, count: count)
        
        await enumerated()
            .lazy
            .map { offset, work in
                {
                    results[offset] = await work()
                }
            }
            .awaitAll(maxConcurrency: maxConcurrency)

        return results.map { result in result.unsafelyUnwrapped }
    }

    func awaitAll<R>(maxConcurrency: Int = .max) async throws -> [R] where Element == () async throws -> R {
        var results = [R?](repeating: nil, count: count)

        try await enumerated()
            .lazy
            .map { offset, work in
                {
                    results[offset] = try await work()
                }
            }
            .awaitAll(maxConcurrency: maxConcurrency)

        return results.map { result in result.unsafelyUnwrapped }
    }
}