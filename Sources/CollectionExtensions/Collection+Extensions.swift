import CompareFunctions
import Foundation

public extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        
        return self[index]
    }
    
    subscript<Indices: Sequence<Index>>(indices: Indices) -> [Element] {
        var result = [Element]()
        
        for index in indices {
            result.append(self[index])
        }
        
        return result
    }
    
    subscript<Indices: Sequence<Index>>(safe indices: Indices) -> [Element] {
        var result = [Element]()
        
        for index in indices {
            if let value = self[safe: index] {
                result.append(value)
            }
        }
        
        return result
    }

    func indices(where condition: (Element) throws -> Bool) rethrows -> [Index] {
        var result = [Index]()
        
        for index in indices where try condition(self[index]) {
            result.append(index)
        }
        
        return result
    }
    
    func indices(
        of elementToFind: Element,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Index] {
        try indices { element in try equality(element, elementToFind) }
    }
    
    func indices<Elements: Sequence<Element>>(
        of elementsToFind: Elements,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Index] {
        try indices(
            of: Array(elementsToFind),
            by: equality
        )
    }
    
    func indices<Elements: Collection<Element>>(
        of elementsToFind: Elements,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Index] {
        let elementsToFind = elementsToFind.store(in: Array.self)
        
        return try indices { element in try elementsToFind.contains(element, by: equality) }
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
    
    mutating func mutableMap<R>(
        _ transform: (inout Element) throws -> R
    ) rethrows -> [R] {
        var results = [R]()
        results.reserveCapacity(count)
        
        for index in indices {
            results.append(try transform(&self[index]))
        }
        
        return results
    }
    
    mutating func mutableCompactMap<R>(
        _ transform: (inout Element) throws -> R?
    ) rethrows -> [R] {
        var results = [R]()
        results.reserveCapacity(count)
        
        for index in indices {
            if let result = try transform(&self[index]) {
                results.append(result)
            }
        }
        
        return results
    }
    
    mutating func mutableFlatMap<R: Sequence>(
        _ transform: (inout Element) throws -> R
    ) rethrows -> [R.Element] {
        var results = [R.Element]()
        
        for index in indices {
            results.append(contentsOf: try transform(&self[index]))
        }
        
        return results
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
        guard indices.contains(index) else {
            return nil
        }
        
        return try mutate(at: index, body)
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
        try mutate(safe: index, body) ?? elseBody()
    }
    
    mutating func mutate<Indices: Sequence<Index>, R>(
        at indices: Indices,
        _ body: (inout Element) throws -> R
    ) rethrows -> [R] {
        var result: [R] = []
        
        for index in indices {
            result.append(try body(&self[index]))
        }
        
        return result
    }
    
    mutating func mutate<Indices: Sequence<Index>>(
        at indices: Indices,
        _ body: (inout Element) throws -> Void
    ) rethrows {
        for index in indices {
            try body(&self[index])
        }
    }
    
    mutating func mutate<Indices: Sequence<Index>, R>(
        safe indices: Indices,
        _ body: (inout Element) throws -> R
    ) rethrows -> [R] {
        var result: [R] = []
        
        for index in indices {
            if var value = self[safe: index] {
                result.append(try body(&value))
                self[index] = value
            }
        }
        
        return result
    }
    
    @discardableResult
    mutating func mutate<Indices: Sequence<Index>>(
        safe indices: Indices,
        _ body: (inout Element) throws -> Void
    ) rethrows -> Int {
        var result = 0
        
        for index in indices {
            if var value = self[safe: index] {
                try body(&value)
                self[index] = value
                
                result += 1
            }
        }
        
        return result
    }
}

extension Collection {
    func removingAll<Target: Sequence<Element>>(
        from target: Target,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> [Element] {
        var result: [Element] = []
        
        for element in target {
            if try contains(element, by: equality) {
                continue
            }
            
            result.append(element)
        }
        
        return result
    }
    
    func removingAll<Target: RangeReplaceableCollection<Element>>(
        from target: Target,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> Target {
        var result = Target()
        
        for element in target {
            if try contains(element, by: equality) {
                continue
            }
            
            result.append(element)
        }
        
        return result
    }
}

public extension RangeReplaceableCollection {
    func appending(
        _ element: Element
    ) -> Self {
        var result = self
        result.append(element)
        return result
    }
    
    func appending(
        _ element: Element,
        if condition: Bool
    ) -> Self {
        condition ? appending(element) : self
    }
    
    func appending<S: Sequence<Element>>(contentsOf sequence: S) -> Self {
        var result = self
        result.append(contentsOf: sequence)
        return result
    }
    
    func appending<S: Sequence<Element>>(
        contentsOf sequence: S,
        if condition: Bool
    ) -> Self {
        condition ? appending(contentsOf: sequence) : self
    }
    
    mutating func prepend(_ element: Element) {
        insert(element, at: startIndex)
    }
    
    func prepending(_ element: Element) -> Self {
        var result = Self()
        result.reserveCapacity(count + 1)
        result.append(element)
        result.append(contentsOf: self)
        
        return result
    }
    
    func prepending(
        _ element: Element,
        if condition: Bool
    ) -> Self {
        condition ? prepending(element) : self
    }
    
    func prepending<S: Sequence<Element>>(contentsOf sequence: S) -> Self {
        Self(sequence).appending(contentsOf: self)
    }
    
    func prepending<S: Sequence<Element>>(
        contentsOf sequence: S,
        if condition: Bool
    ) -> Self {
        condition ? prepending(contentsOf: sequence) : self
    }
    
    func inserting(
        _ element: Element,
        at indexToInsert: Index
    ) -> Self {
        var result = Self()
        result.reserveCapacity(count + 1)
        
        for index in indices {
            if index == indexToInsert {
                result.append(element)
            }
            
            result.append(self[index])
        }
        
        return result
    }
    
    func inserting(
        _ element: Element,
        at index: Index,
        if condition: Bool
    ) -> Self {
        condition ? inserting(element, at: index) : self
    }
    
    func inserting<S: Sequence<Element>>(
        contentsOf sequence: S,
        at indexToInsert: Index
    ) -> Self {
        var result = Self()
        result.reserveCapacity(count + 1)
        
        for index in indices {
            if index == indexToInsert {
                result.append(contentsOf: sequence)
            }
            
            result.append(self[index])
        }
        
        return result
    }
    
    func inserting<S: Sequence<Element>>(
        contentsOf sequence: S,
        at index: Index,
        if condition: Bool
    ) -> Self {
        condition ? inserting(contentsOf: sequence, at: index) : self
    }
    
    func removingAll(
        where condition: (Element) throws -> Bool
    ) rethrows -> Self {
        try filter { element in try !condition(element) }
    }
    
    func removing(at indexToRemove: Index) -> Self {
        var result = Self()
        result.reserveCapacity(count - 1)
        
        for index in indices {
            if index == indexToRemove {
                continue
            }
            
            result.append(self[index])
        }
        
        return result
    }
    
    mutating func remove<Indices: Sequence<Index>>(at indices: Indices) {
        for index in indices.lazy.reversed() {
            remove(at: index)
        }
    }
    
    func removing<Indices: Sequence<Index>>(at indicesToRemove: Indices) -> Self {
        var result = Self()
        result.reserveCapacity(count)
        
        for index in indices {
            if indicesToRemove.contains(index) {
                continue
            }
            
            result.append(self[index])
        }
        
        return result
    }

    mutating func safelyRemoveFirst() -> Element? {
        if let first = self.first {
            removeFirst()
            return first
        }
        
        return nil
    }

    func removingFirst() -> Self {
        var result = Self()
        
        for index in indices {
            if index == indices.startIndex {
                continue
            }
            
            result.append(self[index])
        }
        
        return result
    }

    mutating func removeFirst(where condition: (Element) throws -> Bool) rethrows -> Element? {
        if let index = try firstIndex(where: condition) {
            return remove(at: index)
        }
        
        return nil
    }
    
    func removingFirst(where condition: (Element) throws -> Bool) rethrows -> Self {
        var result = Self()
        
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
    
    mutating func filterInPlace(_ condition: (Element) throws -> Bool) rethrows {
        try removeAll { element in try !condition(element) }
    }
    
    mutating func removeAll(
        of elementToRemove: Element,
        by equality: (Element, Element) throws -> Bool
    ) rethrows {
        try removeAll { element in try equality(element, elementToRemove) }
    }
    
    func removingAll(
        of elementToRemove: Element,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> Self {
        try filter { element in try !equality(element, elementToRemove) }
    }
    
    mutating func removeAll<Elements: Sequence<Element>>(
        of elementsToRemove: Elements,
        by equality: (Element, Element) throws -> Bool
    ) rethrows {
        try elementsToRemove.removeAll(
            from: &self,
            by: equality
        )
    }
    
    func removingAll<Elements: Sequence<Element>>(
        of elementsToRemove: Elements,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> Self {
        try elementsToRemove.removingAll(
            from: self,
            by: equality
        )
    }
    
    func removingAll<Elements: Collection<Element>>(
        of elementsToRemove: Elements,
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> Self {
        try filter { element in try !elementsToRemove.contains(element, by: equality) }
    }

    mutating func removeDuplicates(
        by equality: (Element, Element) throws -> Bool
    ) rethrows {
        var index = startIndex
        
        while index < endIndex {
            var otherIndex = self.index(after: index)
            
            while otherIndex < endIndex {
                let indexToCheck = otherIndex
                formIndex(after: &otherIndex)
                
                if try equality(self[index], self[indexToCheck]) {
                    remove(at: indexToCheck)
                }
            }
            
            formIndex(after: &index)
        }
    }
    
    func removingDuplicates(
        by equality: (Element, Element) throws -> Bool
    ) rethrows -> Self {
        var result = Self()
        
        for element in self {
            if try result.contains(element, by: equality) {
                continue
            }
            
            result.append(element)
        }
        
        return result
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    func indices(of element: Element) -> [Index] {
        indices(of: element, by: ==)
    }
    
    func indices<Elements: Sequence<Element>>(
        of elementsToFind: Elements
    ) -> [Index] {
        indices(of: elementsToFind, by: ==)
    }
    
    func indices<Elements: Collection<Element>>(
        of elementsToFind: Elements
    ) -> [Index] {
        indices(of: elementsToFind, by: ==)
    }
    
    mutating func removeAll(of elementToRemove: Element) {
        removeAll(of: elementToRemove, by: ==)
    }
    
    func removingAll(of elementToRemove: Element) -> Self {
        removingAll(of: elementToRemove, by: ==)
    }
    
    mutating func removeAll<Elements: Sequence<Element>>(of elementsToRemove: Elements) {
        removeAll(of: elementsToRemove, by: ==)
    }

    func removingAll<Elements: Sequence<Element>>(of elementsToRemove: Elements) -> Self {
        removingAll(of: elementsToRemove, by: ==)
    }

    func removingAll<Elements: Collection<Element>>(of elementsToRemove: Elements) -> Self {
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
    mutating func sort(using compare: (Element, Element) throws -> ComparisonResult) rethrows {
        try sort(by: { lhs, rhs in try compare(lhs, rhs) == .orderedAscending })
    }

    mutating func sort<R>(
        by transform: (Element) throws -> R,
        using compare: (R, R) throws -> Bool
    ) rethrows {
        try sort(by: { lhs, rhs in try compare(transform(lhs), transform(rhs)) })
    }
    
    mutating func sort<R>(
        by keyPath: KeyPath<Element, R>,
        using compare: (R, R) throws -> Bool
    ) rethrows {
        try sort(by: { lhs, rhs in try compare(lhs[keyPath: keyPath], rhs[keyPath: keyPath]) })
    }
    
    mutating func sort<R>(
        by transform: (Element) throws -> R,
        using compare: (R, R) throws -> ComparisonResult
    ) rethrows {
        try sort { lhs, rhs in try CompareFunctions.compare(lhs, rhs, by: transform, using: compare) }
    }

    mutating func sort<each Rs: Comparable>(
        by transforms: repeat (Element) -> each Rs
    ) {
        sort { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: repeat each transforms) }
    }
    
    // This crashes on access of the last transform, even if everything is inlined into this package.  Will open a bug report.
//    mutating func trySort<each Rs: Comparable>(
//        by transforms: repeat (Element) throws -> each Rs
//    ) throws {
//        try sort { lhs, rhs in try tryCompare(lhs, rhs, by: repeat each transforms) }
//    }
    
    mutating func sort<each Rs: Comparable>(
        by keyPaths: repeat KeyPath<Element, each Rs>
    ) {
        sort { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: repeat each keyPaths) }
    }
    
    mutating func sort(using compares: (Element, Element) -> ComparisonResult...) {
        sort(using: compares)
    }
    
    mutating func sort(using compares: (Element, Element) throws -> ComparisonResult...) throws {
        try sort(using: compares)
    }
    
    mutating func sort<Compares: Sequence<(Element, Element) -> ComparisonResult>>(using compares: Compares) {
        sort { lhs, rhs in CompareFunctions.compare(lhs, rhs, using: compares) }
    }
    
    mutating func sort<Compares: Sequence<(Element, Element) throws -> ComparisonResult>>(using compares: Compares) throws {
        try sort { lhs, rhs in try CompareFunctions.compare(lhs, rhs, using: compares) }
    }

    mutating func sort<R: Comparable & Equatable, Transforms: Sequence<(Element) -> R>>(by transforms: Transforms) {
        sort { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
    
    mutating func sort<R: Comparable & Equatable, Transforms: Sequence<(Element) throws -> R>>(by transforms: Transforms) throws {
        try sort { lhs, rhs in try CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
    
    mutating func sort<R: Comparable & Equatable, KeyPaths: Sequence<KeyPath<Element, R>>>(by keyPaths: KeyPaths) {
        sort { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: keyPaths) }
    }
}
