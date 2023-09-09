import AsyncExtensions

//extension EnumeratedSequence: @unchecked Sendable where Base: Sendable {}
//extension LazySequence: @unchecked Sendable where Base: Sendable {}
//extension LazyMapSequence: @unchecked Sendable where Base: Sendable {}

struct SmuggledSendableSequence<Base: Sequence>: Sequence, @unchecked Sendable {
    func makeIterator() -> Base.Iterator {
        base.makeIterator()
    }
    
    let base: Base
}

extension Sequence {
    func smuggleSendable() -> SmuggledSendableSequence<Self> {
        .init(base: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Collection where Self: Sendable {
    func awaitAll<R>(maxConcurrency: Int = .max) async -> [R] where Element == AsyncElement<R> {
        let results = UnsafeMutableBufferPointer<R>.allocate(capacity: count)
        defer { results.deallocate() }
     
        await enumerated()
            .lazy
            .map { offset, work in
                { @Sendable in
                    results[offset] = await work()
                }
            }
            .smuggleSendable()
            .awaitAll(maxConcurrency: maxConcurrency)

        return .init(results)
    }

    func awaitAll<R>(maxConcurrency: Int = .max) async throws -> [R] where Element == AsyncThrowingElement<R> {
        let results = UnsafeMutableBufferPointer<R>.allocate(capacity: count)
        defer { results.deallocate() }

        try await enumerated()
            .lazy
            .map { offset, work in
                { @Sendable in
                    results[offset] = try await work()
                }
            }
            .smuggleSendable()
            .awaitAll(maxConcurrency: maxConcurrency)

        return .init(results)
    }
    
    func flattenAwaitAll<R: Collection & Sendable, InnerR>(maxConcurrency: Int = .max) async -> [InnerR] where Element == AsyncElement<R>, R.Element == AsyncElement<InnerR> {
        let results = UnsafeMutableBufferPointer<UnsafeMutableBufferPointer<InnerR>>.allocate(capacity: count)
        defer {
            results.forEach { innerResults in innerResults.deallocate() }
            results.deallocate()
        }
        
        await enumerated()
            .lazy
            .map { outerOffset, outerWork in
                { @Sendable in
                    let outer = await outerWork()
                    
                    results[outerOffset] = .allocate(capacity: outer.count)
                    
                    return outer
                        .enumerated()
                        .lazy
                        .map { innerOffset, innerWork in
                            { @Sendable in
                                results[outerOffset][innerOffset] = await innerWork()
                            }
                        }
                        .smuggleSendable()
                }
            }
            .smuggleSendable()
            .flattenAwaitAll(maxConcurrency: maxConcurrency)

        return results
            .flatten()
    }

    func flattenAwaitAll<R: Collection & Sendable, InnerR>(maxConcurrency: Int = .max) async throws -> [InnerR] where Element == AsyncThrowingElement<R>, R.Element == AsyncThrowingElement<InnerR> {
        let results = UnsafeMutableBufferPointer<UnsafeMutableBufferPointer<InnerR>>.allocate(capacity: count)
        defer {
            results.forEach { innerResults in innerResults.deallocate() }
            results.deallocate()
        }
        
        try await enumerated()
            .lazy
            .map { outerOffset, outerWork in
                { @Sendable in
                    let outer = try await outerWork()
                    
                    results[outerOffset] = .allocate(capacity: outer.count)
                    
                    return outer
                        .enumerated()
                        .lazy
                        .map { innerOffset, innerWork in
                            { @Sendable in
                                results[outerOffset][innerOffset] = try await innerWork()
                            }
                        }
                        .smuggleSendable()
                }
            }
            .smuggleSendable()
            .flattenAwaitAll(maxConcurrency: maxConcurrency)

        return results
            .flatten()
    }
}
