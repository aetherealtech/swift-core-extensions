import ResultExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    func tryFilter(_ condition: @escaping @Sendable (Element) async throws -> Bool) -> AsyncCompactMapSequence<Self, Result<Element, any Error>> {
        compactMap { element in
            let included = await Result { try await condition(element) }
            switch included {
                case let .success(included): return included ? Result<Element, Error>.success(element) : nil
                case let .failure(error): return Result<Element, Error>.failure(error)
            }
        }
    }
    
    func tryMap<R>(_ transform: @escaping @Sendable (Element) async throws -> R) -> AsyncMapSequence<Self, Result<R, any Error>> {
        map { element in await Result { try await transform(element) } }
    }
    
    func tryCompactMap<R>(_ transform: @escaping @Sendable (Element) async throws -> R?) -> AsyncCompactMapSequence<Self, Result<R, any Error>> {
        compactMap { element in
            let innerResult = await Result { try await transform(element) }
            switch innerResult {
                case let .success(innerResult): return innerResult.map(Result<R, Error>.success)
                case let .failure(error): return Result<R, Error>.failure(error)
            }
        }
    }
    
    func tryFlatMap<R: AsyncSequence, InnerR>(_ transform: @escaping @Sendable (Element) async throws -> R) -> AsyncThrowingFlatMapSequence<Self, AnyAsyncSequence<Result<InnerR, any Error>>> where R.Element == InnerR {
        tryFlatMap { outerValue in
            try await transform(outerValue).map { innerValue in Result<InnerR, Error>.success(innerValue) }
        }
    }
    
    func tryFlatMap<R: AsyncSequence, InnerR>(_ transform: @escaping @Sendable (Element) async throws -> R) -> AsyncThrowingFlatMapSequence<Self, AnyAsyncSequence<Result<InnerR, any Error>>> where R.Element == Result<InnerR, any Error> {
        flatMap { element in
            let innerResult = await Result { try await transform(element) }
            switch innerResult {
                case let .success(innerElements): return innerElements.erase()
                case let .failure(error): return [Result<InnerR, Error>.failure(error)].async.erase()
            }
        }
    }
    
    func tryForEach<Success>(_ work: @escaping @Sendable (Success) async throws -> Void) async throws where Element == Result<Success, Error> {
        for try await result in self {
            try await work(result.get())
        }
    }
    
    func filterSuccess<Success>(_ condition: @escaping @Sendable (Success) async throws -> Bool) -> AsyncCompactMapSequence<Self, Result<Success, any Error>> where Element == Result<Success, any Error> {
        compactMap { result in
            switch result {
                case let .success(element):
                    let conditionResult = await Result<Bool, Error> { try await condition(element) }
                    switch conditionResult {
                        case let .success(included): return included ? Result<Success, Error>.success(element) : nil
                        case let .failure(error): return Result<Success, Error>.failure(error)
                    }
                case .failure: return result
            }
        }
    }
    
    func mapSuccess<Success, R>(_ transform: @escaping @Sendable (Success) async throws -> R) -> AsyncMapSequence<Self, Result<R, any Error>> where Element == Result<Success, any Error> {
        map { result in await result.tryMapAsync(transform) }
    }
    
    func compactMapSuccess<Success, R>(_ transform: @escaping @Sendable (Success) async throws -> R?) -> AsyncCompactMapSequence<Self, Result<R, any Error>> where Element == Result<Success, any Error> {
        compactMap { result in
            let innerResult = await result.tryMapAsync(transform)
            switch innerResult {
                case let .success(innerElements): return innerElements.map(Result<R, Error>.success)
                case let .failure(error): return Result<R, Error>.failure(error)
            }
        }
    }
    
    func flatMapSuccess<Success, R: AsyncSequence, InnerR>(_ transform: @escaping @Sendable (Success) async throws -> R) -> AsyncThrowingFlatMapSequence<Self, AnyAsyncSequence<Result<InnerR, any Error>>> where Element == Result<Success, any Error>, R.Element == InnerR {
        flatMapSuccess { outerValue in
            try await transform(outerValue).map { innerValue in Result<InnerR, Error>.success(innerValue) }
        }
    }
    
    func flatMapSuccess<Success, R: AsyncSequence, InnerR>(_ transform: @escaping @Sendable (Success) async throws -> R) -> AsyncThrowingFlatMapSequence<Self, AnyAsyncSequence<Result<InnerR, any Error>>> where Element == Result<Success, any Error>, R.Element == Result<InnerR, any Error> {
        flatMap { result in
            let innerResult = await result.tryMapAsync(transform)
            switch innerResult {
                case let .success(innerElements): return innerElements.erase()
                case let .failure(error): return [Result<InnerR, Error>.failure(error)].async.erase()
            }
        }
    }
    
    func `catch`<Success>(_ catcher: @escaping @Sendable (any Error) async -> Success) -> AsyncMapSequence<Self, Success> where Element == Result<Success, any Error> {
        map { result in
            await result.catchAsync(catcher)
        }
    }
    
    func `catch`<Success, S: AsyncSequence>(_ catcher: @escaping @Sendable (any Error) -> S) -> AsyncThrowingFlatMapSequence<Self, AnyAsyncSequence<Success>> where Element == Result<Success, any Error>, S.Element == Success {
        flatMap { result in
            switch result {
                case let .success(element): return [element].async.erase()
                case let .failure(error): return catcher(error).erase()
            }
        }
    }
    
    func values<Success>() -> AsyncCompactMapSequence<Self, Success> where Element == Result<Success, any Error> {
        compactMap(\.value)
    }
    
    func tryStore<Success, C: RangeReplaceableCollection>(in type: C.Type = C.self) async throws -> C where Element == Result<Success, any Error>, C.Element == Success {
        var stored = C.init()
        for try await result in self {
            stored.append(try result.get())
        }
        
        return stored
    }
    
    func errors<Success>() -> AsyncCompactMapSequence<Self, any Error> where Element == Result<Success, any Error> {
        compactMap(\.error)
    }
    
    func onError<Success>(_ handler: @escaping @Sendable (Error) async -> Void) -> AsyncMapSequence<Self, Element> where Element == Result<Success, any Error> {
        map { result in
            if case let .failure(error) = result {
                await handler(error)
            }
            
            return result
        }
    }
    
    func printErrors<Success>(prefix: String = "") -> AsyncMapSequence<Self, Element> where Element == Result<Success, Error> {
        onError { error in print("\(prefix) \(error.localizedDescription)") }
    }
}
