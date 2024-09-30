//final class AsyncBufferedSequence<Base: AsyncSequence>: AsyncSequence {
//    struct AsyncIterator: AsyncIteratorProtocol {
//        mutating func next() async throws -> Base.Element? {
//            if index < sequence.buffer.count {
//                let result = sequence.buffer[index]
//                index += 1
//                return result
//            } else if let next = try await sequence.iterator.next() {
//                sequence.buffer.append(next)
//                index += 1
//                return next
//            } else {
//                return nil
//            }
//        }
//        
//        let sequence: AsyncBufferedSequence
//        var index = 0
//    }
//    
//    init(base: Base) {
//        iterator = base.makeAsyncIterator()
//    }
//    
//    func makeAsyncIterator() -> AsyncIterator {
//        .init(sequence: self)
//    }
//    
//    private var buffer: [Base.Element] = []
//    private var iterator: Base.AsyncIterator
//}
//
//extension AsyncSequence {
//    func buffered() -> AnyAsyncSequence<Any, any Error> {
//        AsyncBufferedSequence(base: self).fullyErased()
//    }
//}
//
