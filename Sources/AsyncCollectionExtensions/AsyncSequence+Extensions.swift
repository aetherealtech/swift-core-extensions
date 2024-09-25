import CollectionExtensions
import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    func store<C: RangeReplaceableCollection>(in type: C.Type = C.self) async throws -> C where C.Element == Element {
        var result = C()
        
        for try await element in self {
            result.append(element)
        }
        
        return result
    }
    
    func store(in type: Set<Element>.Type = Set.self) async throws -> Set<Element> where Element: Hashable {
        var result = Set<Element>()
        
        for try await element in self {
            result.insert(element)
        }
        
        return result
    }
    
    func store<Key, Value>(in type: [Key: Value].Type = [Key: Value].self) async throws -> [Key: Value] where Element == (Key, Value) {
        try await store(
            in: type,
            uniquingKeysWith: { first, second in second }
        )
    }
    
    func store<Key, Value>(
        in type: [Key: Value].Type = [Key: Value].self,
        uniquingKeysWith: (Value, Value) -> Value
    ) async throws -> [Key: Value] where Element == (Key, Value) {
        var result: [Key: Value] = [:]
        
        for try await (key, value) in self {
            if let existingValue = result[key] {
                result[key] = uniquingKeysWith(existingValue, value)
            } else {
                result[key] = value
            }
        }
        
        return result
    }
    
    func compact<Wrapped>() -> AsyncCompactMapSequence<Self, Wrapped> where Element == Wrapped? {
        compactMap { element in element }
    }

    func flatten<InnerElement>() -> AsyncThrowingFlatMapSequence<Self, Self.Element> where Element: AsyncSequence, Element.Element == InnerElement {
        flatMap { element in element }
    }
    
    func flatten<InnerElement>() -> AsyncFlatMapSequence<Self, SequenceAsyncWrapper<Self.Element>> where Element: Sequence, Element.Element == InnerElement {
        flatMap { element in element.async }
    }
    
    func flatMap<R, InnerElement>(_ transform: @escaping @Sendable (Element) async throws -> R) -> AsyncFlatMapSequence<AsyncThrowingMapSequence<Self, R>, SequenceAsyncWrapper<R>> where R: Sequence, R.Element == InnerElement {
        map(transform)
            .flatten()
    }
    
    func of<T>(type: T.Type) -> AsyncCompactMapSequence<Self, T> {
        compactMap { element in element as? T }
    }
    
    func appending<Elements: AsyncSequence>(
        contentsOf elementsToAppend: Elements
    ) -> AsyncLazyInsertedSequence<Elements, Self> where Elements.Element == Element {
        .init(
            source: elementsToAppend,
            inserted: self,
            insertAt: 0
        )
    }

    func appending(
        _ element: Element
    ) -> AsyncLazyInsertedSequence<SequenceAsyncWrapper<[Element]>, Self> {
        appending(contentsOf: [element].async)
    }

    func prepending<Elements: AsyncSequence>(
        contentsOf elementsToAppend: Elements
    ) -> AsyncLazyInsertedSequence<Self, Elements> where Elements.Element == Element {
        .init(
            source: self,
            inserted: elementsToAppend,
            insertAt: 0
        )
    }

    func prepending(
        _ element: Element
    ) -> AsyncLazyInsertedSequence<Self, SequenceAsyncWrapper<[Element]>> {
        prepending(contentsOf: [element].async)
    }

    func inserting<Elements: AsyncSequence>(
        contentsOf elementsToAppend: Elements,
        at index: Int
    ) -> AsyncLazyInsertedSequence<Self, Elements> where Elements.Element == Element {
        .init(
            source: self,
            inserted: elementsToAppend,
            insertAt: index
        )
    }

    func inserting(
        _ element: Element,
        at index: Int
    ) -> AsyncLazyInsertedSequence<Self, SequenceAsyncWrapper<[Element]>> {
        inserting(contentsOf: [element].async, at: index)
    }

    func removing<Indices: Sequence>(at indices: Indices) -> AsyncMapSequence<AsyncFilterSequence<AsyncEnumeratedSequence<Self>>, Self.Element> where Indices.Element == Int {
        let indices = indices.store(in: Array.self)

        return enumerated()
            .removingAll { index, _ in indices.contains(index) }
            .map(\.element)
    }

    func removing(at index: Int) -> AsyncMapSequence<AsyncFilterSequence<AsyncEnumeratedSequence<Self>>, Self.Element> {
        removing(at: [index])
    }

    func removingAll(
        where condition: @escaping @Sendable (Element) -> Bool
    ) -> AsyncFilterSequence<Self> {
        filter { element in !condition(element) }
    }

    func removingAll<Elements: Sequence>(
        of elementsToRemove: Elements,
        by compare: @escaping @Sendable (Element, Element) -> Bool
    ) -> AsyncFilterSequence<Self> where Element: Sendable, Elements.Element == Element {
        let elementsToRemove = elementsToRemove.store(in: Array.self)

        return removingAll { element in
            elementsToRemove.contains(element, by: compare)
        }
    }

    func removingAll(
        of elementToRemove: Element,
        by compare: @escaping @Sendable (Element, Element) -> Bool
    ) -> AsyncFilterSequence<Self> where Element: Sendable {
        removingAll { element in
            compare(element, elementToRemove)
        }
    }

    func removingDuplicates(
        by compare: @escaping @Sendable (Element, Element) -> Bool
    ) -> AsyncRemoveDuplicatesSequence<Self> {
        .init(
            source: self,
            compare: compare
        )
    }

    func cartesianProduct<Other: AsyncSequence & Sendable>(with other: Other) -> AsyncThrowingFlatMapSequence<Self, AsyncMapSequence<Other, (Self.Element, Other.Element)>> where Element: Sendable, Other.Element: Sendable {
        flatMap { element in
            other
                .map { otherElement in
                    (element, otherElement)
                }
        }
    }

    func first() async rethrows -> Element? {
        for try await element in self {
            return element
        }
        
        return nil
    }
    
    func last() async rethrows -> Element? {
        var result: Element? = nil

        for try await element in self {
            result = element
        }

        return result
    }

    func count() async rethrows -> Int {
        try await reduce(0) { count, _ in count + 1 }
    }

    func contains(atLeast count: Int) async rethrows -> Bool {
        try await prefix(count).count() == count
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence where Element: Equatable {
    func removingAll<Elements: Sequence>(
        of elementsToRemove: Elements
    ) -> AsyncFilterSequence<Self> where Element: Sendable, Elements.Element == Element {
        removingAll(of: elementsToRemove) { lhs, rhs in lhs == rhs }
    }

    func removingAll(
        of elementToRemove: Element
    ) -> AsyncFilterSequence<Self> where Element: Sendable {
        removingAll(of: elementToRemove) { lhs, rhs in lhs == rhs }
    }

    func removingDuplicates() -> AsyncRemoveDuplicatesSequence<Self> {
        removingDuplicates { lhs, rhs in lhs == rhs }
    }
}
