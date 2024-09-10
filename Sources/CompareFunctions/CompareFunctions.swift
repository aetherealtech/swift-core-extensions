import Foundation

public extension Comparable where Self: Equatable {
    static func compare(lhs: Self, rhs: Self) -> ComparisonResult {
        if lhs < rhs { return .orderedAscending }
        if lhs == rhs { return .orderedSame }
        return .orderedDescending
    }
    
    func compare(to other: Self) -> ComparisonResult {
        Self.compare(lhs: self, rhs: other)
    }
}

public func compare<T, R>(
    _ lhs: T,
    _ rhs: T,
    by transform: (T) throws -> R,
    using compare: (R, R) throws -> ComparisonResult
) rethrows -> ComparisonResult {
    try compare(transform(lhs), transform(rhs))
}

public func compare<T, R>(
    _ lhs: T,
    _ rhs: T,
    by keyPath: KeyPath<T, R>,
    using compare: (R, R) throws -> ComparisonResult
) rethrows -> ComparisonResult {
    try compare(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
}

public func compare<T>(
    _ lhs: T,
    _ rhs: T,
    using compares: (T, T) -> ComparisonResult...
) -> ComparisonResult {
    compare(
        lhs,
        rhs,
        using: compares
    )
}

public func compare<T, Compares: Sequence<(T, T) -> ComparisonResult>>(
    _ lhs: T,
    _ rhs: T,
    using compares: Compares
) -> ComparisonResult {
    for compare in compares {
        let result = compare(lhs, rhs)
        if result != .orderedSame {
            return result
        }
    }
    
    return .orderedSame
}

public func compare<T>(
    _ lhs: T,
    _ rhs: T,
    using compares: (T, T) throws -> ComparisonResult...
) throws -> ComparisonResult {
    try compare(
        lhs,
        rhs,
        using: compares
    )
}

public func compare<T, Compares: Sequence<(T, T) throws -> ComparisonResult>>(
    _ lhs: T,
    _ rhs: T,
    using compares: Compares
) throws -> ComparisonResult {
    for compare in compares {
        let result = try compare(lhs, rhs)
        if result != .orderedSame {
            return result
        }
    }
    
    return .orderedSame
}

public func compare<T, R: Comparable & Equatable, Transforms: Sequence<(T) -> R>>(
    _ lhs: T,
    _ rhs: T,
    by transforms: Transforms
) -> ComparisonResult {
    compare(
        lhs,
        rhs,
        using: transforms.map { transform in { lhs, rhs in compare(lhs, rhs, by: transform, using: R.compare) } }
    )
}

public func compare<T, R: Comparable & Equatable, Transforms: Sequence<(T) throws -> R>>(
    _ lhs: T,
    _ rhs: T,
    by transforms: Transforms
) throws -> ComparisonResult {
    try compare(
        lhs,
        rhs,
        using: transforms.map { transform in { lhs, rhs in try tryCompare(lhs, rhs, by: transform) } }
    )
}

public func compare<T, R: Comparable & Equatable, KeyPaths: Sequence<KeyPath<T, R>>>(
    _ lhs: T,
    _ rhs: T,
    by keyPaths: KeyPaths
) -> ComparisonResult {
    compare(
        lhs,
        rhs,
        using: keyPaths.map { keyPath in { lhs, rhs in compare(lhs, rhs, by: keyPath) } }
    )
}

private func nextCompare<T, R: Comparable & Equatable>(
    result: inout ComparisonResult,
    lhs: T,
    rhs: T,
    transform: (T) throws -> R
) rethrows {
    guard result == .orderedSame else {
        return
    }
    
    result = try compare(lhs, rhs, by: transform, using: R.compare)
}

private func nextCompare<T, R: Comparable & Equatable>(
    result: inout ComparisonResult,
    lhs: T,
    rhs: T,
    keyPath: KeyPath<T, R>
) {
    guard result == .orderedSame else {
        return
    }
    
    result = compare(lhs, rhs, by: keyPath, using: R.compare)
}

public func compare<
    T,
    each Rs: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by transforms: repeat (T) -> each Rs
) -> ComparisonResult {
    var result = ComparisonResult.orderedSame
    repeat nextCompare(result: &result, lhs: lhs, rhs: rhs, transform: each transforms)
    
    return result
}

public func tryCompare<
    T,
    each Rs: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by transforms: repeat (T) throws -> each Rs
) throws -> ComparisonResult {
    var result = ComparisonResult.orderedSame
    repeat try nextCompare(result: &result, lhs: lhs, rhs: rhs, transform: each transforms)
    
    return result
}

public func compare<
    T,
    each Rs: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by keyPaths: repeat KeyPath<T, each Rs>
) -> ComparisonResult {
    var result = ComparisonResult.orderedSame
    repeat nextCompare(result: &result, lhs: lhs, rhs: rhs, keyPath: each keyPaths)
    
    return result
}
