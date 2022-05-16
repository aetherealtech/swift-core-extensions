//
//  Created by Daniel Coleman on 1/9/22.
//

import Foundation

public protocol OptionalProtocol {
    
    associatedtype Wrapped
    
    init(_ some: Wrapped)
    
    func map<U>(_ transform: (Wrapped) throws -> U) rethrows -> U?

    func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U?

    init(nilLiteral: ())
    
    var unsafelyUnwrapped: Wrapped { get }
    
    static func ~= (lhs: _OptionalNilComparisonType, rhs: Self) -> Bool
    
    static func == (lhs: Self, rhs: _OptionalNilComparisonType) -> Bool
    static func != (lhs: Self, rhs: _OptionalNilComparisonType) -> Bool
    
    static func == (lhs: _OptionalNilComparisonType, rhs: Self) -> Bool
    static func != (lhs: _OptionalNilComparisonType, rhs: Self) -> Bool
}

extension Optional : OptionalProtocol {
    
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