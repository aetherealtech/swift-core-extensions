import Foundation

public typealias SimpleCompareFunction<T> = (T, T) -> Bool
public typealias CompareFunction<T> = (T, T) -> ComparisonResult

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
    by transform: (T) -> R,
    using compare: CompareFunction<R>
) -> ComparisonResult {
    compare(transform(lhs), transform(rhs))
}

public func compare<T, R>(
    _ lhs: T,
    _ rhs: T,
    by keyPath: KeyPath<T, R>,
    using compare: CompareFunction<R>
) -> ComparisonResult {
    compare(lhs[keyPath: keyPath], rhs[keyPath: keyPath])
}

public func compare<T, R: Comparable>(
    _ lhs: T,
    _ rhs: T,
    by transform: (T) -> R
) -> ComparisonResult {
    compare(lhs, rhs, by: transform, using: R.compare)
}

public func compare<T, R: Comparable>(
    _ lhs: T,
    _ rhs: T,
    by keyPath: KeyPath<T, R>
) -> ComparisonResult {
    compare(lhs, rhs, by: keyPath, using: R.compare)
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

public func compare<T, Compares: Sequence<CompareFunction<T>>>(
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

public func compare<T, R: Comparable & Equatable, Transforms: Sequence<(T) -> R>>(
    _ lhs: T,
    _ rhs: T,
    by transforms: Transforms
) -> ComparisonResult {
    compare(
        lhs,
        rhs,
        using: transforms.map { transform in { lhs, rhs in compare(lhs, rhs, by: transform) } }
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
    
    static func tryCompare<T, R: Comparable & Equatable>(
        _ lhs: T,
        _ rhs: T,
        by keyPath: KeyPath<T, R>
    ) throws -> ComparisonResult {
        try tryCompare(lhs, rhs) { value in value[keyPath: keyPath] }
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

public func compare<
    T,
    each Rs: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by keyPaths: repeat KeyPath<T, each Rs>
) -> ComparisonResult {
    do {
        let _ = (repeat try CompareShortCircuit.tryCompare(lhs, rhs, by: each keyPaths))
    } catch {
        return (error as! CompareShortCircuit).result
    }

    return .orderedSame
}

public enum Compare<T> {
    public static func by<R: Comparable>(
        _ transform: @escaping (T) -> R
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: transform) }
    }
    public static func by<R: Comparable>(
        _ keyPath: KeyPath<T, R>
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: keyPath) }
    }
    
    public static func by<R>(
        _ transform: @escaping (T) -> R,
        using compareFunction: @escaping CompareFunction<R>
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: transform, using: compareFunction)}
    }

    public static func by<R>(
        _ keyPath: KeyPath<T, R>,
        using compareFunction: @escaping CompareFunction<R>
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: keyPath, using: compareFunction)}
    }

    public static func using(
        _  compares: CompareFunction<T>...
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, using: compares)}
    }

    public static func using(
        _  compares: some Sequence<CompareFunction<T>>
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, using: compares)}
    }

    public static func by<R: Comparable & Equatable>(
        _ transforms: some Sequence<(T) -> R>
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: transforms) }
    }

    public static func by<R: Comparable & Equatable>(
        _ keyPaths: some Sequence<KeyPath<T, R>>
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: keyPaths) }
    }

    public static func by<each Rs: Comparable & Equatable>(
        _ transforms: repeat (T) -> each Rs
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: repeat each transforms) }
    }

    public static func by<each Rs: Comparable & Equatable>(
        _ keyPaths: repeat KeyPath<T, each Rs>
    ) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: repeat each keyPaths) }
    }
}
