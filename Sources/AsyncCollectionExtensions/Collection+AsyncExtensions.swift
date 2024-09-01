import AsyncExtensions
import Synchronization

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
public extension Sequence where Self: Sendable {
    func awaitAll<R>(maxConcurrency: Int = .max) async -> [R] where Element == AsyncElement<R> {
        if let collection = self as? any RandomAccessCollection {
            let results = UnsafeMutableBufferPointer<R>.allocate(capacity: collection.count)
            defer { results.deallocate() }
         
            await enumerated()
                .lazy
                .map { offset, work in
                    { @Sendable in
                        (results.baseAddress! + offset).initialize(to: await work())
                    }
                }
                .smuggleSendable()
                .awaitAll(maxConcurrency: maxConcurrency)

            return .init(results)
        } else {
            @Synchronized
            var results: [R?] = []
            
            await enumerated()
                .lazy
                .map { offset, work in
                    { @Sendable [_results] in
                        let value = await work()
                        
                        _results.write { results in
                            if results.count <= offset {
                                results.append(contentsOf: Array.init(repeating: nil, count: offset - results.count + 1))
                            }
                            
                            results[offset] = value
                        }
                    }
                }
                .smuggleSendable()
                .awaitAll(maxConcurrency: maxConcurrency)
            
            return results
                .map { $0.unsafelyUnwrapped } // KeyPath literal crashes compiler
        }
    }

    func awaitAll<R>(maxConcurrency: Int = .max) async throws -> [R] where Element == AsyncThrowingElement<R> {
        if let collection = self as? any RandomAccessCollection {
            let results = UnsafeMutableBufferPointer<R>.allocate(capacity: collection.count)
            defer { results.deallocate() }

            try await enumerated()
                .lazy
                .map { offset, work in
                    { @Sendable in
                        (results.baseAddress! + offset).initialize(to: try await work())
                    }
                }
                .smuggleSendable()
                .awaitAll(maxConcurrency: maxConcurrency)

            return .init(results)
        } else {
            @Synchronized
            var results: [R?] = []
            
            try await enumerated()
                .lazy
                .map { offset, work in
                    { @Sendable [_results] in
                        let value = try await work()
                        
                        _results.write { results in
                            if results.count <= offset {
                                results.append(contentsOf: Array.init(repeating: nil, count: offset - results.count + 1))
                            }
                            
                            results[offset] = value
                        }
                    }
                }
                .smuggleSendable()
                .awaitAll(maxConcurrency: maxConcurrency)
            
            return results
                .map { $0.unsafelyUnwrapped } // KeyPath literal crashes compiler
        }
    }
    
    func flattenAwaitAll<R: Sequence & Sendable, InnerR>(maxConcurrency: Int = .max) async -> [InnerR] where Element == AsyncElement<R>, R.Element == AsyncElement<InnerR> {
        if let collection = self as? any RandomAccessCollection {
            if R.self is any RandomAccessCollection.Type {
                let results = UnsafeMutableBufferPointer<UnsafeMutableBufferPointer<InnerR>>.allocate(capacity: collection.count)
                defer {
                    results.forEach { innerResults in innerResults.deallocate() }
                    results.deallocate()
                }
                
                await enumerated()
                    .lazy
                    .map { outerOffset, outerWork in
                        { @Sendable in
                            let outer = await outerWork()
                            
                            (results.baseAddress! + outerOffset).initialize(to: .allocate(capacity: (outer as! any Collection).count))
                            
                            return outer
                                .enumerated()
                                .lazy
                                .map { innerOffset, innerWork in
                                    { @Sendable in
                                        (results[outerOffset].baseAddress! + innerOffset).initialize(to: await innerWork())
                                    }
                                }
                                .smuggleSendable()
                        }
                    }
                    .smuggleSendable()
                    .flattenAwaitAll(maxConcurrency: maxConcurrency)

                return results
                    .flatten()
            } else {
                let results = UnsafeMutableBufferPointer<Synchronized<[InnerR?]>>.allocate(capacity: collection.count)
                defer {
                    results.deallocate()
                }
                
                await enumerated()
                    .lazy
                    .map { outerOffset, outerWork in
                        { @Sendable in
                            let outer = await outerWork()
                            
                            (results.baseAddress! + outerOffset).initialize(to: .init(wrappedValue: []))
                            
                            return outer
                                .enumerated()
                                .lazy
                                .map { innerOffset, innerWork in
                                    { @Sendable in
                                        let value = await innerWork()
                                        
                                        results[outerOffset].write { innerResults in
                                            if innerResults.count <= innerOffset {
                                                innerResults.append(contentsOf: Array.init(repeating: nil, count: innerOffset - innerResults.count + 1))
                                            }
                                            
                                            innerResults[innerOffset] = value
                                        }
                                    }
                                }
                                .smuggleSendable()
                        }
                    }
                    .smuggleSendable()
                    .flattenAwaitAll(maxConcurrency: maxConcurrency)

                return results
                    .flatMap { innerResults in
                        innerResults.wrappedValue
                            .map { $0.unsafelyUnwrapped } // KeyPath literal crashes compiler
                    }
            }
        } else {
            if R.self is any RandomAccessCollection.Type {
                @Synchronized
                var results: [UnsafeMutableBufferPointer<InnerR>?] = []
                
                defer {
                    results.forEach { innerResults in innerResults.unsafelyUnwrapped.deallocate() }
                }
                
                await enumerated()
                    .lazy
                    .map { outerOffset, outerWork in
                        { @Sendable [_results] in
                            let outer = await outerWork()
                            
                            _results.write { results in
                                if results.count <= outerOffset {
                                    results.append(contentsOf: Array.init(repeating: nil, count: outerOffset - results.count + 1))
                                }
                                
                                results[outerOffset] = .allocate(capacity: (outer as! any Collection).count)
                            }
                            
                            return outer
                                .enumerated()
                                .lazy
                                .map { innerOffset, innerWork in
                                    { @Sendable [_results] in
                                        let innerResults = _results.wrappedValue[outerOffset].unsafelyUnwrapped
                                        
                                        (innerResults.baseAddress! + innerOffset).initialize(to: await innerWork())
                                    }
                                }
                                .smuggleSendable()
                        }
                    }
                    .smuggleSendable()
                    .flattenAwaitAll(maxConcurrency: maxConcurrency)

                return results
                    .flatMap { $0.unsafelyUnwrapped } // KeyPath literal crashes compiler
            } else {
                @Synchronized
                var results: [[InnerR?]] = []
                
                await enumerated()
                    .lazy
                    .map { outerOffset, outerWork in
                        { @Sendable [_results] in
                            let outer = await outerWork()
                            
                            _results.write { results in
                                if results.count <= outerOffset {
                                    results.append(contentsOf: Array.init(repeating: [], count: outerOffset - results.count + 1))
                                }
                            }
                            
                            return outer
                                .enumerated()
                                .lazy
                                .map { innerOffset, innerWork in
                                    { @Sendable [_results] in
                                        let value = await innerWork()
                                        
                                        _results.write { results in
                                            if results[outerOffset].count <= innerOffset {
                                                results[outerOffset].append(contentsOf: Array.init(repeating: nil, count: innerOffset - results[outerOffset].count + 1))
                                            }
                                            
                                            results[outerOffset][innerOffset] = value
                                        }
                                    }
                                }
                                .smuggleSendable()
                        }
                    }
                    .smuggleSendable()
                    .flattenAwaitAll(maxConcurrency: maxConcurrency)
                
                return results
                    .flatMap { innerResults in
                        innerResults
                            .map { $0.unsafelyUnwrapped } // KeyPath literal crashes compiler
                    }
            }
        }
    }

    func flattenAwaitAll<R: Sequence & Sendable, InnerR>(maxConcurrency: Int = .max) async throws -> [InnerR] where Element == AsyncThrowingElement<R>, R.Element == AsyncThrowingElement<InnerR> {
        if let collection = self as? any RandomAccessCollection {
            if R.self is any RandomAccessCollection.Type {
                let results = UnsafeMutableBufferPointer<UnsafeMutableBufferPointer<InnerR>>.allocate(capacity: collection.count)
                defer {
                    results.forEach { innerResults in innerResults.deallocate() }
                    results.deallocate()
                }
                
                try await enumerated()
                    .lazy
                    .map { outerOffset, outerWork in
                        { @Sendable in
                            let outer = try await outerWork()
                            
                            (results.baseAddress! + outerOffset).initialize(to: .allocate(capacity: (outer as! any Collection).count))
                            
                            return outer
                                .enumerated()
                                .lazy
                                .map { innerOffset, innerWork in
                                    { @Sendable in
                                        (results[outerOffset].baseAddress! + innerOffset).initialize(to: try await innerWork())
                                    }
                                }
                                .smuggleSendable()
                        }
                    }
                    .smuggleSendable()
                    .flattenAwaitAll(maxConcurrency: maxConcurrency)

                return results
                    .flatten()
            } else {
                let results = UnsafeMutableBufferPointer<Synchronized<[InnerR?]>>.allocate(capacity: collection.count)
                defer {
                    results.deallocate()
                }
                
                try await enumerated()
                    .lazy
                    .map { outerOffset, outerWork in
                        { @Sendable in
                            let outer = try await outerWork()
                            
                            (results.baseAddress! + outerOffset).initialize(to: .init(wrappedValue: []))
                            
                            return outer
                                .enumerated()
                                .lazy
                                .map { innerOffset, innerWork in
                                    { @Sendable in
                                        let value = try await innerWork()
                                        
                                        results[outerOffset].write { innerResults in
                                            if innerResults.count <= innerOffset {
                                                innerResults.append(contentsOf: Array.init(repeating: nil, count: innerOffset - innerResults.count + 1))
                                            }
                                            
                                            innerResults[innerOffset] = value
                                        }
                                    }
                                }
                                .smuggleSendable()
                        }
                    }
                    .smuggleSendable()
                    .flattenAwaitAll(maxConcurrency: maxConcurrency)

                return results
                    .flatMap { innerResults in
                        innerResults.wrappedValue
                            .map { $0.unsafelyUnwrapped } // KeyPath literal crashes compiler
                    }
            }
        } else {
            if R.self is any RandomAccessCollection.Type {
                @Synchronized
                var results: [UnsafeMutableBufferPointer<InnerR>?] = []
                
                defer {
                    results.forEach { innerResults in innerResults.unsafelyUnwrapped.deallocate() }
                }
                
                try await enumerated()
                    .lazy
                    .map { outerOffset, outerWork in
                        { @Sendable [_results] in
                            let outer = try await outerWork()
                            
                            _results.write { results in
                                if results.count <= outerOffset {
                                    results.append(contentsOf: Array.init(repeating: nil, count: outerOffset - results.count + 1))
                                }
                                
                                results[outerOffset] = .allocate(capacity: (outer as! any Collection).count)
                            }
                            
                            return outer
                                .enumerated()
                                .lazy
                                .map { innerOffset, innerWork in
                                    { @Sendable [_results] in
                                        let innerResults = _results.wrappedValue[outerOffset].unsafelyUnwrapped
                                        
                                        (innerResults.baseAddress! + innerOffset).initialize(to: try await innerWork())
                                    }
                                }
                                .smuggleSendable()
                        }
                    }
                    .smuggleSendable()
                    .flattenAwaitAll(maxConcurrency: maxConcurrency)

                return results
                    .flatMap { $0.unsafelyUnwrapped } // KeyPath literal crashes compiler
            } else {
                @Synchronized
                var results: [[InnerR?]] = []
                
                try await enumerated()
                    .lazy
                    .map { outerOffset, outerWork in
                        { @Sendable [_results] in
                            let outer = try await outerWork()
                            
                            _results.write { results in
                                if results.count <= outerOffset {
                                    results.append(contentsOf: Array.init(repeating: [], count: outerOffset - results.count + 1))
                                }
                            }
                            
                            return outer
                                .enumerated()
                                .lazy
                                .map { innerOffset, innerWork in
                                    { @Sendable [_results] in
                                        let value = try await innerWork()
                                        
                                        _results.write { results in
                                            if results[outerOffset].count <= innerOffset {
                                                results[outerOffset].append(contentsOf: Array.init(repeating: nil, count: innerOffset - results[outerOffset].count + 1))
                                            }
                                            
                                            results[outerOffset][innerOffset] = value
                                        }
                                    }
                                }
                                .smuggleSendable()
                        }
                    }
                    .smuggleSendable()
                    .flattenAwaitAll(maxConcurrency: maxConcurrency)
                
                return results
                    .flatMap { innerResults in
                        innerResults
                            .map { $0.unsafelyUnwrapped } // KeyPath literal crashes compiler
                    }
            }
        }
    }
}
