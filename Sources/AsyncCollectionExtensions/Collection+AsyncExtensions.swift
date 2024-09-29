import AsyncExtensions
import Synchronization

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Sequence where Self: Sendable {
    func awaitAll<R>(maxConcurrency: Int = .max) async -> [R] where Element == AsyncElement<R> {
        let collection = self
            .makeRandomAccess
  
        let stream = collection
            .enumerated()
            .lazy
            .mapSendable { (offset, work) in { @Sendable in (offset, await work()) } }
            .stream(maxConcurrency: maxConcurrency)
        
        var theBuffer: UnsafeMutableBufferPointer<R>!
        
        let result = [R](unsafeUninitializedCapacity: collection.count) { buffer, initializedCount in
            theBuffer = buffer
            initializedCount = collection.count
        }

        for await (offset, element) in stream {
            (theBuffer.baseAddress! + offset).initialize(to: element)
        }

        return result
    }

    func awaitAll<R>(maxConcurrency: Int = .max) async throws -> [R] where Element == AsyncThrowingElement<R> {
        let collection = self
            .makeRandomAccess

        let stream = collection
            .enumerated()
            .lazy
            .mapSendable { (offset, work) in { @Sendable in (offset, try await work()) } }
            .stream(maxConcurrency: maxConcurrency)
        
        var theBuffer: UnsafeMutableBufferPointer<R>!
        
        let result = [R](unsafeUninitializedCapacity: collection.count) { buffer, initializedCount in
            theBuffer = buffer
            initializedCount = collection.count
        }

        for try await (offset, element) in stream {
            (theBuffer.baseAddress! + offset).initialize(to: element)
        }

        return result
    }
}
