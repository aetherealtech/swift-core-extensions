import Foundation

public struct UnwrappedNil: LocalizedError {
    public let message: String
    public let type: Any.Type
    
    public var errorDescription: String? {
        "Attempted to unwrap nil Optional<\(String(describing: type))>: \(message)"
    }
}

public extension Optional {
    func require(_ exceptionIfNil: @autoclosure () -> Error) throws -> Wrapped {
        try self ?? { () -> Wrapped in throw exceptionIfNil() }()
    }

    func require(_ messageIfNil: @autoclosure () -> String) throws -> Wrapped {
        try require(UnwrappedNil(message: messageIfNil(), type: Wrapped.self))
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
    func combine<each Rs>(_ others: repeat (each Rs)?) -> (Wrapped, repeat each Rs)? {
        Optionals.combine(self, repeat each others)
    }
}

public enum Optionals {
    public static func combine<each Ts>(
        _ values: repeat (each Ts)?
    ) -> (repeat each Ts)? {
        do {
            return (repeat try (each values).require(""))
        } catch {
            return nil
        }
    }
}

public extension Collection {
    func combine<Wrapped>() -> [Wrapped]? where Element == Wrapped? {
        var result = [Wrapped]()
        result.reserveCapacity(count)
        
        for value in self {
            guard let value else {
                return nil
            }
            
            result.append(value)
        }
        
        return result
    }
}
