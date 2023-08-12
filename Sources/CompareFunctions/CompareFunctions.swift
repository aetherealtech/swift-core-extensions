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

public func compare<
    T,
    R1: Comparable & Equatable,
    R2: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by transform1: (T) -> R1,
    _ transform2: (T) -> R2
) -> ComparisonResult {
    var result = compare(lhs, rhs, by: transform1)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform2)
    if result != .orderedSame {
        return result
    }
    
    return .orderedSame
}

public func compare<
    T,
    R1: Comparable & Equatable,
    R2: Comparable & Equatable,
    R3: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by transform1: (T) -> R1,
    _ transform2: (T) -> R2,
    _ transform3: (T) -> R3
) -> ComparisonResult {
    var result = compare(lhs, rhs, by: transform1)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform2)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform3)
    if result != .orderedSame {
        return result
    }
    
    return .orderedSame
}

public func compare<
    T,
    R1: Comparable & Equatable,
    R2: Comparable & Equatable,
    R3: Comparable & Equatable,
    R4: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by transform1: (T) -> R1,
    _ transform2: (T) -> R2,
    _ transform3: (T) -> R3,
    _ transform4: (T) -> R4
) -> ComparisonResult {
    var result = compare(lhs, rhs, by: transform1)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform2)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform3)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform4)
    if result != .orderedSame {
        return result
    }
    
    return .orderedSame
}

public func compare<
    T,
    R1: Comparable & Equatable,
    R2: Comparable & Equatable,
    R3: Comparable & Equatable,
    R4: Comparable & Equatable,
    R5: Comparable & Equatable
>(
    _ lhs: T,
    _ rhs: T,
    by transform1: (T) -> R1,
    _ transform2: (T) -> R2,
    _ transform3: (T) -> R3,
    _ transform4: (T) -> R4,
    _ transform5: (T) -> R5
) -> ComparisonResult {
    var result = compare(lhs, rhs, by: transform1)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform2)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform3)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform4)
    if result != .orderedSame {
        return result
    }
    
    result = compare(lhs, rhs, by: transform5)
    if result != .orderedSame {
        return result
    }
    
    return .orderedSame
}

public enum Compare<T> {
    public static func by<R: Comparable>(_ transform: @escaping (T) -> R) -> CompareFunction<T> {
        { lhs, rhs in compare(lhs, rhs, by: transform) }
    }
}
