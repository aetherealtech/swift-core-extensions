public typealias FailingSequence<Element> = Sequence<Result<Element, Error>>

public extension Result where Failure == Error {
    var value: Success? {
        if case let .success(value) = self {
            return value
        }
        
        return nil
    }
    
    var error: Failure? {
        if case let .failure(error) = self {
            return error
        }
        
        return nil
    }
    
    func tryMap<R>(_ transform: (Success) throws -> R) -> Result<R, Error> {
        flatMap { success in Result<R, Error> { try transform(success) } }
    }
}

public extension LazySequenceProtocol {
    func tryFilter(_ condition: @escaping (Element) throws -> Bool) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Result<Self.Element, any Error>?>>, Result<Self.Element, any Error>> {
        compactMap { element in
            let included = Result { try condition(element) }
            switch included {
            case let .success(included): return included ? Result<Element, Error>.success(element) : nil
            case let .failure(error): return Result<Element, Error>.failure(error)
            }
        }
    }
    
    func tryMap<R>(_ transform: @escaping (Element) throws -> R) -> LazyMapSequence<Elements, Result<R, Error>> {
        map { element in Result { try transform(element) } }
    }
    
    func tryCompactMap<R>(_ transform: @escaping (Element) throws -> R?) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Result<R, any Error>?>>, Result<R, any Error>> {
        compactMap { element in
            let innerResult = Result { try transform(element) }
            switch innerResult {
            case let .success(innerResult): return innerResult.map(Result<R, Error>.success)
            case let .failure(error): return Result<R, Error>.failure(error)
            }
        }
    }
    
    func tryFlatMap<R: Sequence, InnerR>(_ transform: @escaping (Element) throws -> R) -> LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, AnyLazySequence<Result<InnerR, any Error>>>>> where R.Element == InnerR {
        flatMap { element in
            let innerResult = Result { try transform(element) }
            switch innerResult {
            case let .success(innerElements): return innerElements.lazy.map(Result<R.Element, Error>.success).lazyErase()
            case let .failure(error): return [Result<R.Element, Error>.failure(error)].lazy.lazyErase()
            }
        }
    }
    
    func tryForEach<Success>(_ work: @escaping (Success) throws -> Void) throws where Element == Result<Success, Error> {
        for result in self {
            try work(result.get())
        }
    }
    
    func filterSuccess<Success>(_ condition: @escaping (Success) throws -> Bool) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Result<Success, any Error>?>>, Result<Success, any Error>> where Element == Result<Success, Error> {
        compactMap { result in
            switch result {
            case let .success(element):
                let conditionResult = Result<Bool, Error> { try condition(element) }
                switch conditionResult {
                case let .success(included): return included ? Result<Success, Error>.success(element) : nil
                case let .failure(error): return Result<Success, Error>.failure(error)
                }
            case .failure: return result
            }
        }
    }
    
    func mapSuccess<Success, R>(_ transform: @escaping (Success) throws -> R) -> LazyMapSequence<Elements, Result<R, Error>> where Element == Result<Success, Error> {
        map { result in result.tryMap(transform) }
    }
    
    func compactMapSuccess<Success, R>(_ transform: @escaping (Success) throws -> R?) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Result<R, any Error>?>>, Result<R, any Error>> where Element == Result<Success, Error> {
        compactMap { result in
            let innerResult = result.tryMap(transform)
            switch innerResult {
            case let .success(innerElements): return innerElements.map(Result<R, Error>.success)
            case let .failure(error): return Result<R, Error>.failure(error)
            }
        }
    }
 
    func flatMapSuccess<Success, R: Sequence, InnerR>(_ transform: @escaping (Success) throws -> R) -> LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, AnyLazySequence<Result<InnerR, any Error>>>>> where Element == Result<Success, Error>, R.Element == InnerR {
        flatMap { result in
            let innerResult = result.tryMap(transform)
            switch innerResult {
            case let .success(innerElements): return innerElements.lazy.map(Result<R.Element, Error>.success).lazyErase()
            case let .failure(error): return [Result<R.Element, Error>.failure(error)].lazy.lazyErase()
            }
        }
    }
    
    func values<Success>() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Success?>>, Success> where Element == Result<Success, Error> {
        compactMap(\.value)
    }
    
    func tryStore<Success, C: RangeReplaceableCollection>(in type: C.Type = C.self) throws -> C where Element == Result<Success, Error>, C.Element == Success {
        var stored = C.init()
        for result in self {
            stored.append(try result.get())
        }
        
        return stored
    }
    
    func errors<Success>() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Self.Elements, Error?>>, Error> where Element == Result<Success, Error> {
        compactMap(\.error)
    }
    
    func onError<Success>(_ handler: @escaping (Error) -> Void) -> LazyMapSequence<Self.Elements, Result<Success, any Error>> where Element == Result<Success, Error> {
        map { result in
            if case let .failure(error) = result {
                handler(error)
            }
            
            return result
        }
    }
    
    func printErrors<Success>(prefix: String = "") -> LazyMapSequence<Self.Elements, Result<Success, any Error>> where Element == Result<Success, Error> {
        onError { error in print("\(prefix) \(error.localizedDescription)") }
    }
}
