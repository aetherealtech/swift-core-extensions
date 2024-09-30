//@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//public enum AsyncIfElseSequence<
//    If: AsyncSequence,
//    Else: AsyncSequence
//>: AsyncSequence where Else.Element == If.Element {
//    case `if`(If)
//    case `else`(Else)
//    
//    public typealias Element = If.Element
//    
//    public enum AsyncIterator: AsyncIteratorProtocol {
//        case `if`(If.AsyncIterator)
//        case `else`(Else.AsyncIterator)
//        
//        public mutating func next() async throws -> Element? {
//            switch self {
//                case var .if(iterator):
//                    guard let next = try await iterator.next() else { return nil }
//                    self = .if(iterator)
//                    return next
//                    
//                case var .else(iterator):
//                    guard let next = try await iterator.next() else { return nil }
//                    self = .else(iterator)
//                    return next
//            }
//        }
//        
//        @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
//        public mutating func next(isolation actor: isolated (any Actor)?) async throws(If.Failure) -> Element? where Else.Failure == If.Failure {
//            switch self {
//                case var .if(iterator):
//                    guard let next = try await iterator.next(isolation: actor) else { return nil }
//                    self = .if(iterator)
//                    return next
//                    
//                case var .else(iterator):
//                    guard let next = try await iterator.next(isolation: actor) else { return nil }
//                    self = .else(iterator)
//                    return next
//            }
//        }
//        
//        @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
//        public mutating func next(isolation actor: isolated (any Actor)?) async throws(any Error) -> Element? {
//            switch self {
//                case var .if(iterator):
//                    guard let next = try await iterator.next(isolation: actor) else { return nil }
//                    self = .if(iterator)
//                    return next
//                    
//                case var .else(iterator):
//                    guard let next = try await iterator.next(isolation: actor) else { return nil }
//                    self = .else(iterator)
//                    return next
//            }
//        }
//    }
//    
//    public func makeAsyncIterator() -> AsyncIterator {
//        switch self {
//            case let .if(base): .if(base.makeAsyncIterator())
//            case let .else(base): .else(base.makeAsyncIterator())
//        }
//    }
//}
