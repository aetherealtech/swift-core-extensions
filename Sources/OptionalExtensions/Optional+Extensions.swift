import Foundation

struct UnwrappedNil<Wrapped>: LocalizedError {
    let message: String

    public var errorDescription: String? {
        "Attempted to unwrap nil Optional<\(String(describing: Wrapped.self))>: \(message)"
    }
}

public extension Optional {
    func require(_ exceptionIfNil: @autoclosure () -> Error) throws -> Wrapped {
        try self ?? { () -> Wrapped in throw exceptionIfNil() }()
    }

    func require(_ messageIfNil: @autoclosure () -> String) throws -> Wrapped {
        try require(UnwrappedNil<Wrapped>(message: messageIfNil()))
    }

    func filter(_ condition: (Wrapped) throws -> Bool) rethrows -> Self {
        if let self, try condition(self) {
            return self
        }
        
        return nil
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func mapAsync<T>(_ transform: (Wrapped) async throws -> T) async rethrows -> T? {
        if let value = self {
            return try await transform(value)
        }

        return nil
    }
    
    func flatten<InnerWrapped>() -> InnerWrapped? where Wrapped == InnerWrapped? {
        flatMap { $0 }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func flatMapAsync<T>(_ transform: (Wrapped) async throws -> T?) async rethrows -> T? {
        try await mapAsync(transform)
            .flatten()
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func filterAsync(_ condition: (Wrapped) async throws -> Bool) async rethrows -> Self {
        if let self, try await condition(self) {
            return self
        }
        
        return nil
    }

    func asArray() -> [Wrapped] {
        map { [$0] } ?? []
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ?? <T>(optional: T?, defaultValue: () async throws -> T) async rethrows -> T {
    if let value = optional {
        return value
    }

    return try await defaultValue()
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ?? <T>(optional: T?, defaultValue: () async throws -> T?) async rethrows -> T? {
    if let value = optional {
        return value
    }

    return try await defaultValue()
}

public extension Optional {
    func combine<R>(_ other: R?) -> (Wrapped, R)? {
        Optionals.combine(self, other)
    }
}

public enum Optionals {
    public static func combine<
        T1,
        T2
    >(
        _ value1: T1?,
        _ value2: T2?
    ) -> (T1, T2)? {
        if let value1, let value2 {
            return (value1, value2)
        } else {
            return nil
        }
    }
    
    public static func combine<
        T1,
        T2,
        T3
    >(
        _ value1: T1?,
        _ value2: T2?,
        _ value3: T3?
    ) -> (T1, T2, T3)? {
        if let (value1, value2) = combine(value1, value2), let value3 {
            return (value1, value2, value3)
        } else {
            return nil
        }
    }
    
    public static func combine<
        T1,
        T2,
        T3,
        T4
    >(
        _ value1: T1?,
        _ value2: T2?,
        _ value3: T3?,
        _ value4: T4?
    ) -> (T1, T2, T3, T4)? {
        if let (value1, value2, value3) = combine(value1, value2, value3), let value4 {
            return (value1, value2, value3, value4)
        } else {
            return nil
        }
    }
    
    public static func combine<
        T1,
        T2,
        T3,
        T4,
        T5
    >(
        _ value1: T1?,
        _ value2: T2?,
        _ value3: T3?,
        _ value4: T4?,
        _ value5: T5?
    ) -> (T1, T2, T3, T4, T5)? {
        if let (value1, value2, value3, value4) = combine(value1, value2, value3, value4), let value5 {
            return (value1, value2, value3, value4, value5)
        } else {
            return nil
        }
    }
}
