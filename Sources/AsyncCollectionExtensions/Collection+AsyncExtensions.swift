import AsyncExtensions

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
    
    func flattenAwaitAll<R: Collection, InnerR>(maxConcurrency: Int = .max) async -> [InnerR] where Element == () async -> R, R.Element == () async -> InnerR {
        var results = [[InnerR?]?](repeating: nil, count: count)
        
        await enumerated()
            .lazy
            .map { outerOffset, outerWork in
                {
                    let outer = await outerWork()
                    
                    results[outerOffset] = [InnerR?](repeating: nil, count: outer.count)
                    
                    return outer
                        .enumerated()
                        .lazy
                        .map { innerOffset, innerWork in
                            {
                                results[outerOffset]![innerOffset] = await innerWork()
                            }
                        }
                }
            }
            .flattenAwaitAll(maxConcurrency: maxConcurrency)

        return .init(results
            .lazy
            .flatMap { outerResult in
                outerResult.unsafelyUnwrapped
                    .lazy
                    .map { innerResult in innerResult.unsafelyUnwrapped }
            })
    }

    func flattenAwaitAll<R: Collection, InnerR>(maxConcurrency: Int = .max) async throws -> [InnerR] where Element == () async throws -> R, R.Element == () async throws -> InnerR {
        var results = [[InnerR?]?](repeating: nil, count: count)
        
        try await enumerated()
            .lazy
            .map { outerOffset, outerWork in
                {
                    let outer = try await outerWork()
                    
                    results[outerOffset] = [InnerR?](repeating: nil, count: outer.count)
                    
                    return outer
                        .enumerated()
                        .lazy
                        .map { innerOffset, innerWork in
                            {
                                results[outerOffset]![innerOffset] = try await innerWork()
                            }
                        }
                }
            }
            .flattenAwaitAll(maxConcurrency: maxConcurrency)

        return .init(results
            .lazy
            .flatMap { outerResult in
                outerResult.unsafelyUnwrapped
                    .lazy
                    .map { innerResult in innerResult.unsafelyUnwrapped }
            })
    }
}
