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

public func ??=<T>(lhs: inout T?, rhs: @autoclosure () -> T) -> T {
    if lhs == nil {
        lhs = rhs()
    }
    return lhs!
}

public func ??=<T>(lhs: inout T?, rhs: @autoclosure () -> T?) -> T? {
    if lhs == nil {
        lhs = rhs()
    }
    return lhs
}