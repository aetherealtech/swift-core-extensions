import CompareFunctions
import Foundation

public extension Dictionary {
    mutating func value(
        at key: Key,
        orInsert newValue: @autoclosure () throws -> Value
    ) rethrows -> Value {
        guard let existing = self[key] else {
            let newValue = try newValue()
            self[key] = newValue
            return newValue
        }
        
        return existing
    }
    
    func inserting(
        key: Key,
        value: Value
    ) -> Self {
        var result = self
        result[key] = value
        return result
    }

    func mapKeys<ResultKey: Hashable>(
        _ transform: (Key) throws -> ResultKey,
        uniquingKeysWith: (Value, Value) throws -> Value
    ) rethrows -> [ResultKey: Value] {
        try lazy.map { element in
            try (transform(element.key), element.value)
        }
        .store(
            in: [ResultKey: Value].self,
            uniquingKeysWith: uniquingKeysWith
        )
    }
    
    func mapKeys<ResultKey: Hashable>(
        _ transform: (Key) throws -> ResultKey
    ) rethrows -> [ResultKey: Value] {
        try lazy.map { element in
            try (transform(element.key), element.value)
        }
        .store(
            in: [ResultKey: Value].self
        )
    }

    func sortedByKeys(
        using compare: (Key, Key) throws -> ComparisonResult
    ) rethrows -> [Element] {
        try sorted(by: { lhs, rhs in try compare(lhs.key, rhs.key) == .orderedAscending })
    }

    func sortedByKeys(
        using compare: (Key, Key) throws -> Bool
    ) rethrows -> [Element] {
        try sorted(by: { lhs, rhs in try compare(lhs.key, rhs.key) })
    }

    func sortedByKeys<R>(
        by transform: (Key) throws -> R,
        using compare: (R, R) throws -> ComparisonResult
    ) rethrows -> [Element] {
        try sortedByKeys { lhs, rhs in try CompareFunctions.compare(lhs, rhs, by: transform, using: compare) }
    }

    func sortedByKeys<R>(
        by transform: (Key) throws -> R,
        using compare: (R, R) throws -> Bool
    ) rethrows -> [Element] {
        try sortedByKeys(using: { lhs, rhs in try compare(transform(lhs), transform(rhs)) })
    }
    
    func sortedByKeys(using compares: (Key, Key) -> ComparisonResult...) -> [Element] {
        sortedByKeys(using: compares)
    }
    
    func sortedByKeys(using compares: (Key, Key) throws -> ComparisonResult...) throws -> [Element] {
        try sortedByKeys(using: compares)
    }
    
    func sortedByKeys<Compares: Collection<(Key, Key) -> ComparisonResult>>(using compares: Compares) -> [Element] {
        sortedByKeys { lhs, rhs in CompareFunctions.compare(lhs, rhs, using: compares) }
    }
    
    func sortedByKeys<Compares: Collection<(Key, Key) throws -> ComparisonResult>>(using compares: Compares) throws -> [Element] {
        try sortedByKeys { lhs, rhs in try CompareFunctions.compare(lhs, rhs, using: compares) }
    }
    
    func sortedByKeys<
        each Rs: Comparable & Equatable
    >(
        by transforms: repeat @escaping (Key) -> each Rs
    ) -> [Element] {
        sorted(by: { lhs, rhs in CompareFunctions.compare(lhs.key, rhs.key, by: repeat each transforms) == .orderedAscending })
    }
    
    func trySortedByKeys<
        each Rs: Comparable & Equatable
    >(
        by transforms: repeat @escaping (Key) throws -> each Rs
    ) throws -> [Element] {
        try sorted(by: { lhs, rhs in try CompareFunctions.tryCompare(lhs.key, rhs.key, by: repeat each transforms) == .orderedAscending })
//        try sortedByKeys { lhs, rhs in try CompareFunctions.tryCompare(lhs, rhs, by: repeat each transforms) }
    }
    
    // Same crash as in Collection+Extensions and Sequence+Extensions
    
//    func trySortedByKeys<
//        each Rs: Comparable & Equatable
//    >(
//        by transforms: repeat @escaping (Key) throws -> each Rs
//    ) throws -> [Element] {
//        try sortedByKeys { lhs, rhs in try CompareFunctions.tryCompare(lhs, rhs, by: repeat each transforms) }
//    }
    
    func sortedByKeys<R: Comparable & Equatable, Transforms: Collection<(Key) -> R>>(by transforms: Transforms) -> [Element] {
        sortedByKeys { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
    
    func sortedByKeys<R: Comparable & Equatable, Transforms: Collection<(Key) throws -> R>>(by transforms: Transforms) throws -> [Element] {
        try sortedByKeys { lhs, rhs in try CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
    
    func sortedByKeys() -> [Element] where Key: Comparable {
        sortedByKeys(using: <)
    }

    func allKeys(
        where condition: (Element) throws -> Bool
    ) rethrows -> Set<Key> {
        try filter(condition)
            .lazy
            .map(\.key)
            .store()
    }
    
    func allKeys(
        for valueToMatch: Value,
        by equality: (Value, Value) throws -> Bool
    ) rethrows -> Set<Key> {
        try allKeys { key, value in try equality(value, valueToMatch) }
    }
    
    func allKeys(
        for valueToMatch: Value
    ) -> Set<Key> where Value: Equatable {
        allKeys(for: valueToMatch, by: ==)
    }

    mutating func mutableForEachValues(
        _ body: (inout Value) throws -> Void
    ) rethrows {
        for (key, var value) in self {
            try body(&value)
            self[key] = value
        }
    }
    
    mutating func mapValuesInPlace(
        _ transform: (Value) throws -> Value
    ) rethrows {
        try mutableForEachValues { value in
            value = try transform(value)
        }
    }
    
    @discardableResult
    mutating func mutate<R>(
        at key: Key,
        _ work: (inout Value?) -> R
    ) -> R {
        var value = self[key]
        let result = work(&value)
        self[key] = value

        return result
    }

    @discardableResult
    mutating func mutate<R>(
        at key: Key,
        defaultValue: @autoclosure () -> Value,
        _ work: (inout Value) -> R
    ) -> R {
        var value = self[key] ?? defaultValue()
        let result = work(&value)
        self[key] = value

        return result
    }
    
    mutating func filterInPlace(_ condition: (Element) throws -> Bool) rethrows {
        for element in self where try !condition(element) {
            self[element.key] = nil
        }
    }
    
    func filter(_ condition: (Element) -> Bool) -> Self {
        var result = Self()
        
        for element in self {
            if !condition(element) {
                continue
            }
            
            result[element.key] = element.value
        }
        
        return result
    }
    
    mutating func filterKeysInPlace(_ condition: (Key) throws -> Bool) rethrows {
        try filterInPlace { key, _ in try !condition(key) }
    }
    
    func filterKeys(_ condition: (Key) throws -> Bool) rethrows -> Self {
        try filter { key, _ in try !condition(key) }
    }
    
    mutating func filterValuesInPlace(_ condition: (Value) throws -> Bool) rethrows {
        try filterInPlace { _, value in try !condition(value) }
    }
    
    func filterValues(_ condition: (Value) throws -> Bool) rethrows -> Self {
        try filter { _, value in try !condition(value) }
    }

    mutating func remove(where condition: (Element) throws -> Bool) rethrows {
        try filterInPlace { element in try !condition(element) }
    }
    
    func removing(_ condition: (Element) throws -> Bool) rethrows -> Self {
        try filter { element in try !condition(element) }
    }
    
    mutating func removeKeys(where condition: (Key) throws -> Bool) rethrows {
        try filterInPlace { key, _ in try !condition(key) }
    }
    
    func removingKeys(_ condition: (Key) throws -> Bool) rethrows -> Self {
        try filter { key, _ in try !condition(key) }
    }
    
    mutating func removeValues(where condition: (Value) throws -> Bool) rethrows {
        try filterInPlace { _, value in try !condition(value) }
    }
    
    func removingValues(_ condition: (Value) throws -> Bool) rethrows -> Self {
        try filter { _, value in try !condition(value) }
    }
    
    mutating func remove<Keys: Sequence<Key>>(
        keys keysToRemove: Keys,
        by equality: (Key, Key) throws -> Bool
    ) rethrows {
        for keyToRemove in keysToRemove {
            for key in keys {
                if try equality(key, keyToRemove) {
                    self[key] = nil
                }
            }
        }
    }
    
    func removing<Keys: Sequence<Key>>(
        keys keysToRemove: Keys,
        by equality: (Key, Key) throws -> Bool
    ) rethrows -> Self where Keys.Element == Key {
        var result = self
        try result.remove(keys: keysToRemove, by: equality)
        return result
    }
    
    mutating func remove<Keys: Sequence<Key>>(
        keys keysToRemove: Keys
    ) {
        for key in keysToRemove {
            self[key] = nil
        }
    }
    
    func removing<Keys: Sequence<Key>>(
        keys keysToRemove: Keys
    ) -> Self {
        var result = self
        result.remove(keys: keysToRemove)
        return result
    }
    
    mutating func remove<Values: Sequence<Value>>(
        values valuesToRemove: Values,
        by equality: (Value, Value) throws -> Bool
    ) rethrows {
        for valueToRemove in valuesToRemove {
            for (key, value) in self {
                if try equality(value, valueToRemove) {
                    self[key] = nil
                }
            }
        }
    }
    
    func removing<Values: Sequence<Value>>(
        values valuesToRemove: Values,
        by equality: (Value, Value) throws -> Bool
    ) rethrows -> Self {
        var result = self
        try result.remove(values: valuesToRemove, by: equality)
        return result
    }
    
    mutating func remove<Values: Sequence<Value>>(
        values valuesToRemove: Values
    ) where Value: Equatable {
        remove(values: valuesToRemove, by: ==)
    }
    
    func removing<Values: Sequence>(
        values valuesToRemove: Values
    ) -> Self where Values.Element == Value, Value: Equatable {
        removing(values: valuesToRemove, by: ==)
    }
}
