import CompareFunctions
import Foundation

public extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        
        return self[index]
    }
    
    subscript<Indices: Sequence>(indices: Indices) -> [Element] where Indices.Element == Index {
        var result = [Element]()
        
        for index in indices {
            result.append(self[index])
        }
        
        return result
    }
    
    func contains(_ element: Element, by compare: SimpleCompareFunction<Element>) -> Bool {
        contains { otherElement in compare(element, otherElement) }
    }
    
    func cartesianProduct<Other: Collection>(with other: Other) -> [(Element, Other.Element)] {
        flatMap { element in
            other.map { otherElement in
                (element, otherElement)
            }
        }
    }
    
    func indices(where condition: (Element) -> Bool) -> [Index] {
        var result = [Index]()
        
        for index in indices where condition(self[index]) {
            result.append(index)
        }
        
        return result
    }
    
    func indices(
        of elementToFind: Element,
        by compare: SimpleCompareFunction<Element>
    ) -> [Index] {
        indices { element in compare(element, elementToFind) }
    }
    
    func indices<Elements: Sequence>(
        of elementsToFind: Elements,
        by compare: SimpleCompareFunction<Element>
    ) -> [Index] where Elements.Element == Element {
        let elementsToFind = elementsToFind.store(in: Array.self)
        
        return indices { element in elementsToFind.contains(element, by: compare) }
    }
}

public extension Collection {
    func immutable(_ mutator: (inout Self) -> Void) -> Self {
        var result = self
        mutator(&result)
        return result
    }
}

public extension MutableCollection {
    mutating func mutableForEach(
        _ body: (inout Element) throws -> Void
    ) rethrows {
        for index in indices {
            try body(&self[index])
        }
    }
    
    mutating func mapInPlace(
        _ transform: (Element) throws -> Element
    ) rethrows {
        try mutableForEach { value in
            value = try transform(value)
        }
    }
    
    @discardableResult
    mutating func mutate<R>(
        at index: Index,
        _ body: (inout Element) throws -> R
    ) rethrows -> R {
        try body(&self[index])
    }
    
    @discardableResult
    mutating func mutate<R>(
        safe index: Index,
        _ body: (inout Element) throws -> R
    ) rethrows -> R? {
        if var value = self[safe: index] {
            defer { self[index] = value }
            return try body(&value)
        } else {
            return nil
        }
    }
    
    @discardableResult
    mutating func mutate(
        safe index: Index,
        _ body: (inout Element) throws -> Void
    ) rethrows -> Bool {
        try mutate(safe: index) { element in
            try body(&element)
            return true
        } ?? false
    }
    
    @discardableResult
    mutating func mutate<R>(
        safe index: Index,
        _ body: (inout Element) throws -> R,
        else elseBody: () throws -> R
    ) rethrows -> R {
        if var value = self[safe: index] {
            defer { self[index] = value }
            return try body(&value)
        } else {
            return try elseBody()
        }
    }
    
    mutating func mutate<Indices: Sequence>(
        at indices: Indices,
        _ body: (inout Element) throws -> Void
    ) rethrows where Indices.Element == Index {
        for index in indices {
            try body(&self[index])
        }
    }
}

extension Sequence {
    func removeAll<Target: RangeReplaceableCollection>(
        from target: inout Target,
        by compare: SimpleCompareFunction<Element>
    ) where Target.Element == Element {
        for elementToRemove in self {
            target.removeAll(of: elementToRemove, by: compare)
        }
    }
}

extension Collection {
    func removeAll<Target: RangeReplaceableCollection>(
        from target: inout Target,
        by compare: SimpleCompareFunction<Element>
    ) where Target.Element == Element {
        target.removeAll { element in self.contains(element, by: compare) }
    }
}

public extension RangeReplaceableCollection {
    func appending(
        _ element: Element
    ) -> Self {
        immutable { result in
            result.append(element)
        }
    }
    
    func appending(
        _ element: Element,
        if condition: Bool
    ) -> Self {
        condition ? appending(element) : self
    }
    
    func appending<S: Sequence>(contentsOf sequence: S) -> Self where S.Element == Element {
        immutable { result in
            result.append(contentsOf: sequence)
        }
    }
    
    mutating func prepend(_ element: Element) {
        insert(element, at: startIndex)
    }
    
    func prepending(_ element: Element) -> Self {
        immutable { result in
            result.prepend(element)
        }
    }
    
    func prepending(
        _ element: Element,
        if condition: Bool
    ) -> Self {
        condition ? prepending(element) : self
    }
    
    func inserting(
        _ element: Element,
        at index: Index
    ) -> Self {
        immutable { result in
            result.insert(element, at: index)
        }
    }
    
    func inserting(
        _ element: Element,
        at index: Index,
        if condition: Bool
    ) -> Self {
        condition ? inserting(element, at: index) : self
    }
    
    func removingAll(
        where condition: (Element) -> Bool
    ) -> Self {
        filter { element in !condition(element) }
    }
    
    func removing(at index: Index) -> Self {
        immutable { result in
            result.remove(at: index)
        }
    }
    
    mutating func remove<Indices: Sequence>(at indices: Indices) where Indices.Element == Index {
        for index in indices.reversed() {
            remove(at: index)
        }
    }
    
    func removing<Indices: Sequence>(at indices: Indices) -> Self where Indices.Element == Index {
        immutable { result in
            result.remove(at: indices)
        }
    }
    
    mutating func removeFirst(where condition: (Element) -> Bool) -> Element? {
        if let index = firstIndex(where: condition) {
            return remove(at: index)
        }
        
        return nil
    }
    
    mutating func filterInPlace(_ condition: (Element) throws -> Bool) rethrows {
        try removeAll { element in try !condition(element) }
    }
    
    mutating func removeAll(
        of elementToRemove: Element,
        by compare: SimpleCompareFunction<Element>
    ) {
        removeAll { element in compare(element, elementToRemove) }
    }
    
    func removingAll(
        of elementToRemove: Element,
        by compare: SimpleCompareFunction<Element>
    ) -> Self {
        filter { element in compare(element, elementToRemove) }
    }
    
    mutating func removeAll<Elements: Sequence>(
        of elementsToRemove: Elements,
        by compare: SimpleCompareFunction<Element>
    ) where Elements.Element == Element {
        elementsToRemove.removeAll(
            from: &self,
            by: compare
        )
    }
    
    func removingAll<Elements: Sequence>(
        of elementsToRemove: Elements,
        by compare: SimpleCompareFunction<Element>
    ) -> Self where Elements.Element == Element {
        immutable { result in
            result.removeAll(of: elementsToRemove, by: compare)
        }
    }
    
    func removingAll<Elements: Collection>(
        of elementsToRemove: Elements,
        by compare: SimpleCompareFunction<Element>
    ) -> Self where Elements.Element == Element {
        filter { element in elementsToRemove.contains(element, by: compare) }
    }
    
    private var removeDuplicateFilter: (Element, SimpleCompareFunction<Element>) -> Bool {
        var checked = [Element]()
        
        return { element, compare in
            if checked.contains(element, by: compare) {
                return false
            } else {
                checked.append(element)
                return true
            }
        }
    }
    
    mutating func removeDuplicates(
        by compare: SimpleCompareFunction<Element>
    ) {
        let removeFilter = removeDuplicateFilter
        return filterInPlace { element in removeFilter(element, compare) }
    }
    
    func removingDuplicates(
        by compare: SimpleCompareFunction<Element>
    ) -> Self {
        let removeFilter = removeDuplicateFilter
        return filter { element in removeFilter(element, compare) }
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    func indices(of element: Element) -> [Index] {
        indices(of: element, by: ==)
    }
    
    func indices<Elements: Sequence>(
        of elementsToFind: Elements
    ) -> [Index] where Elements.Element == Element {
        indices(of: elementsToFind, by: ==)
    }
    
    mutating func removeAll(of elementToRemove: Element) {
        removeAll(of: elementToRemove, by: ==)
    }
    
    func removingAll(of elementToRemove: Element) -> Self {
        removingAll(of: elementToRemove, by: ==)
    }
    
    mutating func removeAll<Elements: Sequence>(of elementsToRemove: Elements) where Elements.Element == Element {
        removeAll(of: elementsToRemove, by: ==)
    }

    func removingAll<Elements: Sequence>(of elementsToRemove: Elements) -> Self where Elements.Element == Element {
        removingAll(of: elementsToRemove, by: ==)
    }

    mutating func removeDuplicates() {
        removeDuplicates(by: ==)
    }
    
    func removingDuplicates() -> Self {
        removingDuplicates(by: ==)
    }
}

public extension RandomAccessCollection where Self: MutableCollection {
    mutating func sort(using compare: CompareFunction<Element>) {
        sort(by: { lhs, rhs in compare(lhs, rhs) == .orderedAscending })
    }

    mutating func sort<R>(by transform: (Element) -> R, using compare: SimpleCompareFunction<R>) {
        sort(by: { lhs, rhs in compare(transform(lhs), transform(rhs)) })
    }
    
    mutating func sort<R: Comparable>(by transform: (Element) -> R) {
        sort(by: transform, using: <)
    }
    
    mutating func sort<R>(by transform: (Element) -> R, using compare: CompareFunction<R>) {
        sort { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transform, using: compare) }
    }
    
    mutating func sort(using compares: CompareFunction<Element>...) {
        sort(using: compares)
    }
    
    mutating func sort<Compares: Sequence>(using compares: Compares) where Compares.Element == CompareFunction<Element> {
        sort { lhs, rhs in CompareFunctions.compare(lhs, rhs, using: compares) }
    }
    
    mutating func sort<R: Comparable & Equatable>(by transforms: (Element) -> R...) {
        sort(by: transforms)
    }
    
    mutating func sort<R: Comparable & Equatable, Transforms: Sequence>(by transforms: Transforms) where Transforms.Element == (Element) -> R {
        sort { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
}
