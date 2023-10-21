infix operator ??=: AssignmentPrecedence

/// Assign `lhs` to `rhs` if the `lhs` is `nil`, then return the new value of `lhs`, which is always non-nil
public func ??= <T>(lhs: inout T?, rhs: @autoclosure () throws -> T) rethrows -> T {
    try lhs.assignIfNil(rhs())
}

/// Assign `lhs` to `rhs` if the `lhs` is `nil`, then return the new value of `lhs`
public func ??= <T>(lhs: inout T?, rhs: @autoclosure () throws -> T?) rethrows -> T? {
    try lhs.assignIfNil(rhs())
}

/// Assign `lhs` to `rhs` if the `lhs` is `nil`, then return the new value of `lhs`, which is always non-nil
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ??= <T>(lhs: inout T?, rhs: () async throws -> T) async rethrows -> T {
    try await lhs.assignIfNil(rhs)
}

/// Assign `lhs` to `rhs` if the `lhs` is `nil`, then return the new value of `lhs`
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ??= <T>(lhs: inout T?, rhs: () async throws -> T?) async rethrows -> T? {
    try await lhs.assignIfNil(rhs)
}

public extension Optional {
    /// Assign `value` to the receiver  if the receiver  is `nil`, then return the new value of the receiver, which is always non-nil
    @discardableResult
    mutating func assignIfNil(_ value: @autoclosure () throws -> Wrapped) rethrows -> Wrapped {
        switch self {
            case .none:
                let newValue = try value()
                self = newValue
                return newValue
            case let .some(existing):
                return existing
        }
    }

    /// Assign `value` to the receiver  if the receiver  is `nil`, then return the new value of the receiver
    @discardableResult
    mutating func assignIfNil(_ value: @autoclosure () throws -> Wrapped?) rethrows -> Wrapped? {
        switch self {
            case .none:
                let newValue = try value()
                self = newValue
                return newValue
            case let .some(existing):
                return existing
        }
    }
    
    /// Assign `value` to the receiver  if the receiver  is `nil`, then return the new value of the receiver, which is always non-nil
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @discardableResult
    mutating func assignIfNil(_ value: () async throws -> Wrapped) async rethrows -> Wrapped {
        switch self {
            case .none:
                let newValue = try await value()
                self = newValue
                return newValue
            case let .some(existing):
                return existing
        }
    }
    
    /// Assign `value` to the receiver  if the receiver  is `nil`, then return the new value of the receiver
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    @discardableResult
    mutating func assignIfNil(_ value: () async throws -> Wrapped?) async rethrows -> Wrapped? {
        switch self {
            case .none:
                let newValue = try await value()
                self = newValue
                return newValue
            case let .some(existing):
                return existing
        }
    }
}
