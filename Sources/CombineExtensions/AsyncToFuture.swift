import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
private struct SmuggledPromise<Output, Failure: Error>: @unchecked Sendable {
    let promise: Future<Output, Failure>.Promise
    
    func callAsFunction(_ result: Result<Output, Failure>) {
        promise(result)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Future where Failure == Never {
    convenience init(
        executing function: @escaping @Sendable () async -> Output
    ) {
        self.init { promise in
            Task { [promise = SmuggledPromise(promise: promise)] in
                promise(.success(await function()))
            }
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Future where Failure == Error {
    convenience init(
        executing function: @escaping @Sendable () async throws -> Output
    ) {
        self.init { promise in
            Task { [promise = SmuggledPromise(promise: promise)] in
                promise(await .init(catching: function))
            }
        }
    }
}
