//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ??<T>(lhs: T?, rhs: @autoclosure () async throws -> T) async rethrows -> T {
    if let lhs {
        return lhs
    }
    
    return try await rhs()
}

infix operator ??= : AssignmentPrecedence

public func ??=<T>(lhs: inout T?, rhs: @autoclosure () throws -> T) rethrows -> T {
    if lhs == nil {
        lhs = try rhs()
    }
    return lhs!
}

public func ??=<T>(lhs: inout T?, rhs: @autoclosure () throws -> T?) rethrows -> T? {
    if lhs == nil {
        lhs = try rhs()
    }
    return lhs
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ??=<T>(lhs: inout T?, rhs: @autoclosure (() async throws -> T)) async rethrows -> T {
    if lhs == nil {
        lhs = try await rhs()
    }
    return lhs!
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public func ??=<T>(lhs: inout T?, rhs: @autoclosure (() async throws -> T?)) async rethrows -> T? {
    if lhs == nil {
        lhs = try await rhs()
    }
    return lhs
}
