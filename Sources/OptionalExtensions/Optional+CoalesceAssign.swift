infix operator ??=: AssignmentPrecedence

public func ??= <T>(lhs: inout T?, rhs: @autoclosure () throws -> T) rethrows -> T {
    try lhs.assignIfNil(rhs())
}

public func ??= <T>(lhs: inout T?, rhs: @autoclosure () throws -> T?) rethrows -> T? {
    try lhs.assignIfNil(rhs())
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ??= <T>(lhs: inout T?, rhs: () async throws -> T) async rethrows -> T {
    try await lhs.assignIfNil(rhs)
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ??= <T>(lhs: inout T?, rhs: () async throws -> T?) async rethrows -> T? {
    try await lhs.assignIfNil(rhs)
}

public extension Optional {
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
