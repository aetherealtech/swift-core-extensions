import CompareFunctions
import Foundation

public extension Dictionary {
    func inserting(key: Key, value: Value) -> Self {
        immutable { result in
            result[key] = value
        }
    }

    func mapKeys<ResultKey: Hashable>(
        _ transform: (Key) throws -> ResultKey,
        uniquingKeysWith: (Value, Value) -> Value
    ) rethrows -> [ResultKey: Value] {
        try map { element in
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
        try map { element in
            try (transform(element.key), element.value)
        }
        .store(
            in: [ResultKey: Value].self
        )
    }

    func sortedByKeys(using compare: CompareFunction<Key>) -> [(key: Key, value: Value)] {
        keys
            .sorted(using: compare)
            .map { key in (key, self[key]!) }
    }

    func sortedByKeys(by compare: SimpleCompareFunction<Key>) -> [(key: Key, value: Value)] {
        keys
            .sorted(by: compare)
            .map { key in (key, self[key]!) }
    }

    func sortedByKeys<R>(by transform: (Element) -> R, using compare: SimpleCompareFunction<R>) -> [(key: Key, value: Value)] {
        sorted(by: { lhs, rhs in compare(transform(lhs), transform(rhs)) })
    }
    
    func sortedByKeys<R: Comparable>(by transform: (Element) -> R) -> [Element] {
        sorted(by: transform, using: <)
    }
    
    func sortedByKeys<R>(by transform: (Element) -> R, using compare: CompareFunction<R>) -> [(key: Key, value: Value)] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transform, using: compare) }
    }
    
    func sortedByKeys(using compares: CompareFunction<Key>...) -> [Element] {
        sortedByKeys(using: compares)
    }
    
    func sortedByKeys<Compares: Sequence>(using compares: Compares) -> [(key: Key, value: Value)] where Compares.Element == CompareFunction<Key> {
        sortedByKeys { lhs, rhs in CompareFunctions.compare(lhs, rhs, using: compares) }
    }
    
    func sortedByKeys<R: Comparable & Equatable>(by transforms: (Key) -> R...) -> [(key: Key, value: Value)] {
        sortedByKeys(by: transforms)
    }
    
    func sortedByKeys<R: Comparable & Equatable, Transforms: Sequence>(by transforms: Transforms) -> [(key: Key, value: Value)] where Transforms.Element == (Key) -> R {
        sortedByKeys { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
    
    func sortedByKeys<
        R1: Comparable & Equatable,
        R2: Comparable & Equatable
    >(
        by transform1: (Key) -> R1,
        by transform2: (Key) -> R2
    ) -> [(key: Key, value: Value)] {
        sortedByKeys { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transform1, transform2) }
    }
    
    func sortedByKeys<
        R1: Comparable & Equatable,
        R2: Comparable & Equatable,
        R3: Comparable & Equatable
    >(
        by transform1: (Key) -> R1,
        by transform2: (Key) -> R2,
        by transform3: (Key) -> R3
    ) -> [(key: Key, value: Value)] {
        sortedByKeys { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transform1, transform2, transform3) }
    }
    
    func sortedByKeys<
        R1: Comparable & Equatable,
        R2: Comparable & Equatable,
        R3: Comparable & Equatable,
        R4: Comparable & Equatable
    >(
        by transform1: (Key) -> R1,
        by transform2: (Key) -> R2,
        by transform3: (Key) -> R3,
        by transform4: (Key) -> R4
    ) -> [(key: Key, value: Value)] {
        sortedByKeys { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transform1, transform2, transform3, transform4) }
    }
    
    func sortedByKeys<
        R1: Comparable & Equatable,
        R2: Comparable & Equatable,
        R3: Comparable & Equatable,
        R4: Comparable & Equatable,
        R5: Comparable & Equatable
    >(
        by transform1: (Key) -> R1,
        by transform2: (Key) -> R2,
        by transform3: (Key) -> R3,
        by transform4: (Key) -> R4,
        by transform5: (Key) -> R5
    ) -> [(key: Key, value: Value)] {
        sortedByKeys { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transform1, transform2, transform3, transform4, transform5) }
    }
    
    func sortedByKeys() -> [(key: Key, value: Value)] where Key: Comparable {
        sortedByKeys(by: <)
    }

//    func sortedByKeys(options: NSString.CompareOptions) -> [(key: Key, value: Value)] where Key == String {
//        sortedByKeys(by: String.compareFunction(options: options))
//    }

    func allKeys(
        where condition: (Element) -> Bool
    ) -> Set<Key> {
        lazy
            .filter(condition)
            .map(\.key)
            .store()
    }
    
    func allKeys(
        for valueToMatch: Value,
        by compare: SimpleCompareFunction<Value>
    ) -> Set<Key> {
        allKeys { key, value in compare(value, valueToMatch) }
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
    mutating func mutate<R>(at key: Key, defaultValue: @autoclosure () -> Value, _ work: (inout Value) -> R) -> R {
        var value = self[key] ?? defaultValue()
        let result = work(&value)
        self[key] = value

        return result
    }
    
    mutating func inPlaceFilter(_ condition: (Element) -> Bool) {
        for element in self where !condition(element) {
            self[element.key] = nil
        }
    }
    
    func filter(_ condition: (Element) -> Bool) -> Self {
        immutable { result in
            result.inPlaceFilter(condition)
        }
    }
    
    mutating func inPlaceFilterKeys(_ condition: (Key) -> Bool) {
        inPlaceFilter { key, _ in !condition(key) }
    }
    
    func filterKeys(_ condition: (Key) -> Bool) -> Self {
        immutable { result in
            result.inPlaceFilterKeys(condition)
        }
    }
    
    mutating func inPlaceFilterValues(_ condition: (Value) -> Bool) {
        inPlaceFilter { _, value in !condition(value) }
    }
    
    func filterValues(_ condition: (Value) -> Bool) -> Self {
        immutable { result in
            result.inPlaceFilterValues(condition)
        }
    }
    
    mutating func remove(where condition: (Element) -> Bool) {
        inPlaceFilter { element in !condition(element) }
    }
    
    func removing(_ condition: (Element) -> Bool) -> Self {
        immutable { result in
            result.remove(where: condition)
        }
    }
    
    mutating func removeKeys(where condition: (Key) -> Bool) {
        inPlaceFilter { key, _ in !condition(key) }
    }
    
    func removingKeys(_ condition: (Key) -> Bool) -> Self {
        immutable { result in
            result.removeKeys(where: condition)
        }
    }
    
    mutating func removeValues(where condition: (Value) -> Bool) {
        inPlaceFilter { _, value in !condition(value) }
    }
    
    func removingValues(_ condition: (Value) -> Bool) -> Self {
        immutable { result in
            result.removeValues(where: condition)
        }
    }
    
    mutating func remove<Keys: Sequence>(
        keys keysToRemove: Keys,
        by compare: SimpleCompareFunction<Key>
    ) where Keys.Element == Key {
        let keysToRemove = keysToRemove.store(in: Set.self)
        
        removeKeys { key in keysToRemove.contains(key, by: compare) }
    }
    
    func removing<Keys: Sequence>(
        keys keysToRemove: Keys,
        by compare: SimpleCompareFunction<Key>
    ) -> Self where Keys.Element == Key {
        immutable { result in
            result.remove(keys: keysToRemove, by: compare)
        }
    }
    
    mutating func remove<Keys: Sequence>(
        keys keysToRemove: Keys
    ) where Keys.Element == Key {
        remove(keys: keysToRemove, by: ==)
    }
    
    func removing<Keys: Sequence>(
        keys keysToRemove: Keys
    ) -> Self where Keys.Element == Key {
        removing(keys: keysToRemove, by: ==)
    }
    
    mutating func remove<Values: Sequence>(
        values valuesToRemove: Values,
        by compare: SimpleCompareFunction<Value>
    ) where Values.Element == Value {
        let valuesToRemove = valuesToRemove.store(in: Array.self)
        
        removeValues { value in valuesToRemove.contains(value, by: compare) }
    }
    
    func removing<Values: Sequence>(
        values valuesToRemove: Values,
        by compare: SimpleCompareFunction<Value>
    ) -> Self where Values.Element == Value {
        immutable { result in
            result.remove(values: valuesToRemove, by: compare)
        }
    }
    
    mutating func remove<Values: Sequence>(
        values valuesToRemove: Values
    ) where Values.Element == Value, Value: Equatable {
        remove(values: valuesToRemove, by: ==)
    }
    
    func removing<Values: Sequence>(
        values valuesToRemove: Values
    ) -> Self where Values.Element == Value, Value: Equatable {
        removing(values: valuesToRemove, by: ==)
    }
}

