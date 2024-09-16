import CompareFunctions
import Foundation

public extension Sequence {
    func store<C: RangeReplaceableCollection>(in type: C.Type = C.self) -> C where C.Element == Element {
        .init(self)
    }
    
    func store(in type: Set<Element>.Type = Set.self) -> Set<Element> where Element: Hashable {
        .init(self)
    }
    
    func store<Key, Value>(in type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Element == (Key, Value) {
        .init(uniqueKeysWithValues: self)
    }
    
    func store<Key, Value>(
        in type: [Key: Value].Type = [Key: Value].self,
        uniquingKeysWith: (Value, Value) throws -> Value
    ) rethrows -> [Key: Value] where Element == (Key, Value) {
        try .init(
            self,
            uniquingKeysWith: uniquingKeysWith
        )
    }
    
    func compact<Wrapped>() -> [Wrapped] where Element == Wrapped? {
        compactMap { element in element }
    }
    
    func flatten<InnerElement>() -> [InnerElement] where Element: Sequence, Element.Element == InnerElement {
        flatMap { element in element }
    }

    func grouped<Key: Hashable>(by grouper: (Element) throws -> Key) rethrows -> [Key: [Element]] {
        try .init(grouping: self, by: grouper)
    }
    
    func sorted(using compare: (Element, Element) throws -> ComparisonResult) rethrows -> [Element] {
        try sorted(by: { lhs, rhs in try compare(lhs, rhs) == .orderedAscending })
    }

    func sorted<R>(
        by transform: (Element) throws -> R,
        using compare: (R, R) throws -> Bool
    ) rethrows -> [Element] {
        try sorted(by: { lhs, rhs in try compare(transform(lhs), transform(rhs)) })
    }
    
    func sorted<R>(
        by keyPath: KeyPath<Element, R>,
        using compare: (R, R) throws -> Bool
    ) rethrows -> [Element] {
        try sorted(by: { lhs, rhs in try compare(lhs[keyPath: keyPath], rhs[keyPath: keyPath]) })
    }
    
    func sorted<each Rs: Comparable>(by transforms: repeat @escaping (Element) -> each Rs) -> [Element] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: repeat each transforms) }
    }
    
    func trySorted<each Rs: Comparable>(by transforms: repeat @escaping (Element) throws -> each Rs) throws -> [Element] {
        try sorted { lhs, rhs in try CompareFunctions.tryCompare(lhs, rhs, by: repeat each transforms) }
    }
    
    func sorted<each Rs: Comparable>(by keyPaths: repeat KeyPath<Element, each Rs>) -> [Element] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: repeat each keyPaths) }
    }
    
    func sorted<R>(by transform: (Element) throws -> R, using compare: (R, R) throws -> ComparisonResult) rethrows -> [Element] {
        try sorted { lhs, rhs in try CompareFunctions.compare(lhs, rhs, by: transform, using: compare) }
    }
    
    func sorted(using compares: (Element, Element) -> ComparisonResult...) -> [Element] {
        sorted(using: compares)
    }
    
    func sorted<Compares: Collection<(Element, Element) -> ComparisonResult>>(using compares: Compares) -> [Element] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, using: compares) }
    }
    
    func sorted(using compares: (Element, Element) throws -> ComparisonResult...) throws -> [Element] {
        try sorted(using: compares)
    }
    
    func sorted<Compares: Collection<(Element, Element) throws -> ComparisonResult>>(using compares: Compares) throws -> [Element] {
        try sorted { lhs, rhs in try CompareFunctions.compare(lhs, rhs, using: compares) }
    }

    func sorted<R: Comparable & Equatable, Transforms: Collection<(Element) -> R>>(by transforms: Transforms) -> [Element] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
    
    func sorted<R: Comparable & Equatable, Transforms: Collection<(Element) throws -> R>>(by transforms: Transforms) throws -> [Element] {
        try sorted { lhs, rhs in try CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
    
    func sorted<R: Comparable & Equatable, KeyPaths: Collection<KeyPath<Element, R>>>(by keyPaths: KeyPaths) -> [Element] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: keyPaths) }
    }
    
    func contains(_ element: Element, by equality: (Element, Element) throws -> Bool) rethrows -> Bool {
        try contains { otherElement in try equality(element, otherElement) }
    }

    func removeAll<Target: RangeReplaceableCollection<Element>>(
        from target: inout Target,
        by equality: (Element, Element) throws -> Bool
    ) rethrows {
        for elementToRemove in self {
            try target.removeAll(of: elementToRemove, by: equality)
        }
    }
    
    func removingAll<Target: RangeReplaceableCollection<Element>>(
        from target: Target,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> Target {
        try Array(self).removingAll(
            from: target,
            by: equality
        )
    }

    func removingAll<Target: Sequence<Element>>(
        from target: Target,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Element] {
        try Array(self).removingAll(
            from: target,
            by: equality
        )
    }
    
    func erase() -> AnySequence<Element> {
        .init(self)
    }
    
    func fullyErased() -> AnySequence<Any> {
        let result: LazyMapSequence<Self, Any> = lazy
            .map { $0 as Any }
        
        return result
            .erase()
    }
}

public extension Sequence {
    func appending(
        _ element: Element
    ) -> [Element] {
        Array(self)
            .appending(element)
    }
    
    func appending(
        _ element: Element,
        if condition: Bool
    ) -> [Element] {
        Array(self)
            .appending(element, if: condition)
    }
    
    func appending<S: Sequence<Element>>(contentsOf sequence: S) -> [Element] {
        Array(self)
            .appending(contentsOf: sequence)
    }
    
    func appending<S: Sequence<Element>>(
        contentsOf sequence: S,
        if condition: Bool
    ) -> [Element] {
        Array(self)
            .appending(contentsOf: sequence, if: condition)
    }

    func prepending(_ element: Element) -> [Element] {
        var result: [Element] = []
        result.append(element)
        result.append(contentsOf: self)
        
        return result
    }
    
    func prepending(
        _ element: Element,
        if condition: Bool
    ) -> [Element] {
        condition ? prepending(element) : Array(self)
    }
    
    func inserting(
        _ elementToInsert: Element,
        at indexToInsert: Int
    ) -> [Element] {
        var result: [Element] = []
        
        for (index, element) in enumerated() {
            if index == indexToInsert {
                result.append(elementToInsert)
            }
            
            result.append(element)
        }
        
        return result
    }
    
    func inserting(
        _ element: Element,
        at index: Int,
        if condition: Bool
    ) -> [Element] {
        condition ? inserting(element, at: index) : Array(self)
    }
    
    func removingAll(
        where condition: (Element) throws -> Bool
    ) rethrows -> [Element] {
        try filter { element in try !condition(element) }
    }
    
    func removing(at indexToRemove: Int) -> [Element] {
        var result: [Element] = []
        
        for (index, element) in enumerated() {
            if index == indexToRemove {
                continue
            }
            
            result.append(element)
        }
        
        return result
    }
    
    func removing<Indices: Sequence<Int>>(at indices: Indices) -> [Element] {
        var result: [Element] = []
        
        for (index, element) in enumerated() {
            if indices.contains(index) {
                continue
            }
            
            result.append(element)
        }
        
        return result
    }

    func removingFirst() -> [Element] {
        var result: [Element] = []
        
        var iterator = makeIterator()
        _ = iterator.next()
        
        while let next = iterator.next() {
            result.append(next)
        }
        
        return result
    }

    func removingFirst(where condition: (Element) throws -> Bool) rethrows -> [Element] {
        var result: [Element] = []
        
        var removed = false
        
        for element in self {
            if !removed, try condition(element) {
                removed = true
                continue
            }
            
            result.append(element)
        }
        
        return result
    }

    func removingAll(
        of elementToRemove: Element,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Element] {
        try filter { element in try !equality(element, elementToRemove) }
    }

    func removingAll<Elements: Sequence<Element>>(
        of elementsToRemove: Elements,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Element] {
        try elementsToRemove.removingAll(
            from: self,
            by: equality
        )
    }
    
    func removingAll<Elements: Collection<Element>>(
        of elementsToRemove: Elements,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Element] {
        try filter { element in try !elementsToRemove.contains(element, by: equality) }
    }
    
    func removingDuplicates(
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Element] {
        var result: [Element] = []
        
        for element in self {
            if try result.contains(element, by: equality) {
                continue
            }
            
            result.append(element)
        }
        
        return result
    }
}

public extension Sequence {
    func cartesianProduct<each Others: Sequence>(
        with others: repeat each Others
    ) -> [(Element, repeat (each Others).Element)] {
        Sequences.cartesianProduct(self, repeat each others)
    }
    
    func zip<each Others: Sequence>(
        with others: repeat each Others
    ) -> [(Element, repeat (each Others).Element)] {
        Sequences.zip(self, repeat each others)
    }
}

private func arrayToTuple<each Ts>(_ values: some Sequence) -> (repeat each Ts) {
    var iterator = values.makeIterator()
    
    return (repeat iterator.next() as! each Ts)
}

public enum Sequences {
    static func cartesianProduct<each S: Sequence>(
        _ sequences: repeat each S
    ) -> [(repeat (each S).Element)] {
        var erasedSequences = [any Sequence]()
        
        repeat (erasedSequences.append(each sequences))
        
        let erasedResult = cartesianProduct(erasedSequences)
        
        return erasedResult
            .map { erasedValue in arrayToTuple(erasedValue) }
    }
    
    static func zip<each S: Sequence>(
        _ sequences: repeat each S
    ) -> [(repeat (each S).Element)] {
        var erasedSequences = [any Sequence]()
        
        repeat (erasedSequences.append(each sequences))
        
        let erasedResult = zip(erasedSequences)
        
        return erasedResult
            .map { erasedValue in arrayToTuple(erasedValue) }
    }
    
    private static func cartesianProduct(
        _ sequences: [any Sequence]
    ) -> [[Any]] {
        guard !sequences.isEmpty else {
            return []
        }
        
        enum IteratorState {
            case iterating(Int, AnyIterator<Any>.Iterator)
            case finished(Int)
  
            var count: Int? {
                switch self {
                    case let .finished(count): count
                    default: nil
                }
            }
        }
        
        var iterators: [IteratorState] = sequences
            .map { .iterating(0, $0.fullyErased().makeIterator()) }
        
        var currentIndex: [Int] = sequences
            .map { _ in 0 }
        
        var results: [[Any]] = []
        var done = false
        
        while true {
            let nextValue = iterators.indices.reversed()
                .map { outerIndex in
                    switch iterators[outerIndex] {
                        case let .iterating(index, iterator):
                            if index != currentIndex[outerIndex] {
                                break
                            }
                            
                            if let next = iterator.next() {
                                iterators[outerIndex] = .iterating(index + 1, iterator)
                                return next
                            } else {
                                iterators[outerIndex] = .finished(currentIndex[outerIndex])
                                currentIndex[outerIndex] = 0
                                if outerIndex > 0 {
                                    currentIndex[outerIndex - 1] += 1
                                }
                            }
                            
                        case .finished:
                            break
                    }
                    
                    let lookupIndex = currentIndex.enumerated()
                        .map { oIndex, currentIndex in oIndex <= outerIndex ? currentIndex : 0 }
                    
                    let strides = currentIndex.indices
                        .map { oIndex in iterators[(oIndex + 1)...].map { $0.count ?? 0 }.reduce(1, *) }
                    
                    let resultIndex = (outerIndex..<lookupIndex.count)
                        .map { oIndex in lookupIndex[oIndex] * strides[oIndex] }
                        .reduce(0, +)
                    
                    return results[resultIndex][outerIndex]
                }
            
            results.append(nextValue.reversed())
            
            currentIndex[currentIndex.count - 1] += 1
            
            for index in currentIndex.indices.reversed() {
                if let count = iterators[index].count, currentIndex[index] == count {
                    currentIndex[index] = 0
                    if index == 0 {
                        done = true
                        break
                    }
                    currentIndex[index - 1] += 1
                }
            }
            
            if done {
                break
            }
        }
        
        return results
    }
    
    private static func zip(
        _ sequences: [any Sequence]
    ) -> [[Any]] {
        guard !sequences.isEmpty else {
            return []
        }
        
        var results = [[Any]]()
        
        let iterators = sequences
            .map { $0.fullyErased().makeIterator() }
        
        while true {
            let value = iterators.compactMap { $0.next() }
            
            if value.count < sequences.count {
                break
            }
            
            results .append(value)
        }
        
        return results
    }
}
