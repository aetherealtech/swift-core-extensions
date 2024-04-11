import ResultExtensions

public typealias FailingSequence<Element> = Sequence<Result<Element, any Error>>

public extension LazySequenceProtocol {
    func tryFilter(_ condition: @escaping (Element) throws -> Bool) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Result<Self.Element, any Error>?>>, Result<Self.Element, any Error>> {
        compactMap { element in
            let included = Result { try condition(element) }
            switch included {
                case let .success(included): return included ? Result<Element, any Error>.success(element) : nil
                case let .failure(error): return Result<Element, any Error>.failure(error)
            }
        }
    }
    
    func tryMap<R>(_ transform: @escaping (Element) throws -> R) -> LazyMapSequence<Elements, Result<R, any Error>> {
        map { element in Result { try transform(element) } }
    }
    
    func tryCompactMap<R>(_ transform: @escaping (Element) throws -> R?) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Result<R, any Error>?>>, Result<R, any Error>> {
        compactMap { element in
            let innerResult = Result { try transform(element) }
            switch innerResult {
                case let .success(innerResult): return innerResult.map(Result<R, any Error>.success)
                case let .failure(error): return Result<R, any Error>.failure(error)
            }
        }
    }
    
    func tryFlatMap<R: Sequence, InnerR>(_ transform: @escaping (Element) throws -> R) -> LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, AnyLazySequence<Result<InnerR, any Error>>>>> where R.Element == InnerR {
        tryFlatMap { outerValue in
            try transform(outerValue).lazy.map(Result<InnerR, any Error>.success)
        }
    }
    
    func tryFlatMap<R: Sequence, InnerR>(_ transform: @escaping (Element) throws -> R) -> LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, AnyLazySequence<Result<InnerR, any Error>>>>> where R.Element == Result<InnerR, any Error> {
        flatMap { element in
            let innerResult = Result { try transform(element) }
            switch innerResult {
                case let .success(innerElements): return innerElements.lazy.lazyErase()
                case let .failure(error): return [Result<InnerR, any Error>.failure(error)].lazy.lazyErase()
            }
        }
    }
    
    func tryForEach<Success>(_ work: @escaping (Success) throws -> Void) throws where Element == Result<Success, any Error> {
        for result in self {
            try work(result.get())
        }
    }
    
    func filterSuccess<Success>(_ condition: @escaping (Success) throws -> Bool) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Result<Success, any Error>?>>, Result<Success, any Error>> where Element == Result<Success, any Error> {
        compactMap { result in
            switch result {
                case let .success(element):
                    let conditionResult = Result<Bool, any Error> { try condition(element) }
                    switch conditionResult {
                        case let .success(included): return included ? Result<Success, any Error>.success(element) : nil
                        case let .failure(error): return Result<Success, any Error>.failure(error)
                    }
                case .failure: return result
            }
        }
    }
    
    func mapSuccess<Success, R>(_ transform: @escaping (Success) throws -> R) -> LazyMapSequence<Elements, Result<R, any Error>> where Element == Result<Success, any Error> {
        map { result in result.tryMap(transform) }
    }
    
    func compactMapSuccess<Success, R>(_ transform: @escaping (Success) throws -> R?) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Result<R, any Error>?>>, Result<R, any Error>> where Element == Result<Success, any Error> {
        compactMap { result in
            let innerResult = result.tryMap(transform)
            switch innerResult {
                case let .success(innerElements): return innerElements.map(Result<R, any Error>.success)
                case let .failure(error): return Result<R, any Error>.failure(error)
            }
        }
    }
    
    func flatMapSuccess<Success, R: Sequence, InnerR>(_ transform: @escaping (Success) throws -> R) -> LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, AnyLazySequence<Result<InnerR, any Error>>>>> where Element == Result<Success, any Error>, R.Element == InnerR {
        flatMapSuccess { outerValue in
            try transform(outerValue).lazy.map(Result<InnerR, any Error>.success)
        }
    }
    
    func flatMapSuccess<Success, R: Sequence, InnerR>(_ transform: @escaping (Success) throws -> R) -> LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, AnyLazySequence<Result<InnerR, any Error>>>>> where Element == Result<Success, any Error>, R.Element == Result<InnerR, any Error> {
        flatMap { result in
            let innerResult = result.tryMap(transform)
            switch innerResult {
                case let .success(innerElements): return innerElements.lazy.lazyErase()
                case let .failure(error): return [Result<InnerR, any Error>.failure(error)].lazy.lazyErase()
            }
        }
    }
    
    func `catch`<Success>(_ catcher: @escaping (any Error) -> Success) -> LazyMapSequence<Elements, Success> where Element == Result<Success, any Error> {
        map { result in
            result.catch(catcher)
        }
    }
    
    func `catch`<Success, S: Sequence<Success>>(_ catcher: @escaping (any Error) -> S) -> LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, AnyLazySequence<Success>>>> where Element == Result<Success, any Error> {
        flatMap { result in
            switch result {
                case let .success(element): return [element].lazy.lazyErase()
                case let .failure(error): return catcher(error).lazy.lazyErase()
            }
        }
    }
    
    func values<Success>() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Success?>>, Success> where Element == Result<Success, any Error> {
        compactMap(\.value)
    }
    
    func tryStore<Success, C: RangeReplaceableCollection>(in type: C.Type = C.self) throws -> C where Element == Result<Success, any Error>, C.Element == Success {
        var stored = C.init()
        for result in self {
            stored.append(try result.get())
        }
        
        return stored
    }
    
    func errors<Success>() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, (any Error)?>>, any Error> where Element == Result<Success, any Error> {
        compactMap(\.error)
    }
    
    func onError<Success>(_ handler: @escaping (Error) -> Void) -> LazyMapSequence<Self.Elements, Result<Success, any Error>> where Element == Result<Success, any Error> {
        map { result in
            if case let .failure(error) = result {
                handler(error)
            }
            
            return result
        }
    }
    
    func printErrors<Success>(prefix: String = "") -> LazyMapSequence<Self.Elements, Result<Success, any Error>> where Element == Result<Success, any Error> {
        onError { error in print("\(prefix) \(error.localizedDescription)") }
    }
}
