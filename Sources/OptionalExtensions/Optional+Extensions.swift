import Foundation

/// An error indicating that an optional value was required but was absent.
public struct UnwrappedNil: LocalizedError {
    public let message: String
    public let type: Any.Type
    
    public var errorDescription: String? {
        "Attempted to unwrap nil Optional<\(String(describing: type))>: \(message)"
    }
}

public extension Optional {
    /// Return the value if one is present, otherwise throw the error produced by `exceptionIfNil`.  Identical to `!`, except a `nil` produces an error that can be caught instead of a `fatalError`.
    func require(_ exceptionIfNil: @autoclosure () -> Error) throws -> Wrapped {
        try self ?? { () -> Wrapped in throw exceptionIfNil() }()
    }

    /// Return the value if one is present, otherwise throw an ``UnwrappedNil`` error with the message provided by `messageIfNil`.  See ``require(_:)-w0dg``.
    func require(_ messageIfNil: @autoclosure () -> String) throws -> Wrapped {
        try require(UnwrappedNil(message: messageIfNil(), type: Wrapped.self))
    }

    /// Returns the value if it is present and satisfies the `condition`, otherwise returns `nil`.
    func filter(_ condition: (Wrapped) throws -> Bool) rethrows -> Self {
        if let self, try condition(self) {
            return self
        }
        
        return nil
    }
    
    /// Identical to `Optional.map(:_)`, except the `transform` can be `async`.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func mapAsync<T>(_ transform: (Wrapped) async throws -> T) async rethrows -> T? {
        if let value = self {
            return try await transform(value)
        }

        return nil
    }
    
    /// Flattens a `T??` to a `T?`, which is `nil` if either the inner or outer value is `nil`, or contains the inner value if present.
    func flatten<InnerWrapped>() -> InnerWrapped? where Wrapped == InnerWrapped? {
        flatMap { $0 }
    }
    
    /// Identical to `Optional.flatMap(:_)`, except the `transform` can be `async`.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func flatMapAsync<T>(_ transform: (Wrapped) async throws -> T?) async rethrows -> T? {
        try await mapAsync(transform)
            .flatten()
    }
    
    /// Identical to ``filter(_:)``, except the `condition` can be `async`.
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func filterAsync(_ condition: (Wrapped) async throws -> Bool) async rethrows -> Self {
        if let self, try await condition(self) {
            return self
        }
        
        return nil
    }

    /// Returns an array containing only the value if it is present, otherwise returns an empty array
    func asArray() -> [Wrapped] {
        map { [$0] } ?? []
    }
}

/// Identical to the built-in `??` operator, except the `defaultValue` can be `async`.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ?? <T>(optional: T?, defaultValue: () async throws -> T) async rethrows -> T {
    if let value = optional {
        return value
    }

    return try await defaultValue()
}

/// Identical to the built-in `??` operator, except the `defaultValue` can be `async`.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ?? <T>(optional: T?, defaultValue: () async throws -> T?) async rethrows -> T? {
    if let value = optional {
        return value
    }

    return try await defaultValue()
}

public extension Optional {
    /// Returns an optional tuple that contains the receiver's value and all the `others`' values if they are all present, and returns `nil` if any of those values are absent.  See ``Optionals``.
    func combine<each Rs>(_ others: repeat (each Rs)?) -> (Wrapped, repeat each Rs)? {
        Optionals.combine(self, repeat each others)
    }
}

public enum Optionals {
    /// Returns an optional tuple that contains all the `values`' if they are all present, and returns `nil` if any of those values are absent.
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
    /// Returns an optional array that contains all the values of all the receiver's elements if they are all present, and returns `nil` if any of those values are absent.
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
