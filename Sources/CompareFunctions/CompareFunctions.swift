import Foundation

public typealias SimpleCompareFunction<T> = (T, T) -> Bool
public typealias CompareFunction<T> = (T, T) -> ComparisonResult

public extension Comparable where Self: Equatable {
    static func < (lhs: Self, rhs: Self) -> ComparisonResult {
        if lhs < rhs { return .orderedAscending }
        if lhs == rhs { return .orderedSame }
        return .orderedDescending
    }
}

public func compare<T, R>(
    _ lhs: T,
    _ rhs: T,
    by transform: (T) -> R,
    using compare: CompareFunction<R>
) -> ComparisonResult {
    compare(transform(lhs), transform(rhs))
}

public func compare<T, R: Comparable>(
    _ lhs: T,
    _ rhs: T,
    by transform: (T) -> R
) -> ComparisonResult {
    compare(lhs, rhs, by: transform, using: <)
}

public func compare<T>(
    _ lhs: T,
    _ rhs: T,
    using compares: CompareFunction<T>...
) -> ComparisonResult {
    compare(
        lhs,
        rhs,
        using: compares
    )
}

public func compare<T, Compares: Sequence>(
    _ lhs: T,
    _ rhs: T,
    using compares: Compares
) -> ComparisonResult where Compares.Element == CompareFunction<T> {
    for compare in compares {
        let result = compare(lhs, rhs)
        if result != .orderedSame {
            return result
        }
    }
    
    return .orderedSame
}

public func compare<T, R: Comparable & Equatable>(
    _ lhs: T,
    _ rhs: T,
    by transforms: (T) -> R...
) -> ComparisonResult {
    compare(
        lhs,
        rhs,
        by: transforms
    )
}

public func compare<T, R: Comparable & Equatable, Transforms: Sequence>(
    _ lhs: T,
    _ rhs: T,
    by transforms: Transforms
) -> ComparisonResult where Transforms.Element == (T) -> R {
    compare(
        lhs,
        rhs,
        using: transforms.map { transform in { lhs, rhs in compare(lhs, rhs, by: transform) } }
    )
}

private struct CompareShortCircuit: Error {
    let result: ComparisonResult
    
    static func tryCompare<T, R: Comparable & Equatable>(
        _ lhs: T,
        _ rhs: T,
        by transform: (T) -> R
    ) throws -> ComparisonResult {
        let result = compare(
            lhs,
            rhs,
            by: transform
        )
        
        if result != .orderedSame {
            throw CompareShortCircuit(result: result)
        }
        
        return .orderedSame
    }
}

public func compare<
    T,
    each Rs: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by transforms: repeat (T) -> each Rs
) -> ComparisonResult {
    do {
        let _ = (repeat try CompareShortCircuit.tryCompare(lhs, rhs, by: each transforms))
    } catch {
        return (error as! CompareShortCircuit).result
    }

    return .orderedSame
}

public enum Compare<T> {
    public static func by<R: Comparable>(_ transform: @escaping (T) -> R) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: transform) }
    }
}
