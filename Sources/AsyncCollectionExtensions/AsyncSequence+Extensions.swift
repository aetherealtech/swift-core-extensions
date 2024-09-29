import CollectionExtensions
import Foundation
import PrivateUtilities

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    @_alwaysEmitIntoClient @inlinable
    func store<C: RangeReplaceableCollection>(in type: C.Type = C.self) async rethrows -> C where C.Element == Element {
        var result = C()
        
        for try await element in self {
            result.append(element)
        }
        
        return result
    }
    
    @_alwaysEmitIntoClient @inlinable
    func store(in type: Set<Element>.Type = Set.self) async rethrows -> Set<Element> where Element: Hashable {
        var result = Set<Element>()
        
        for try await element in self {
            result.insert(element)
        }
        
        return result
    }
    
    @_alwaysEmitIntoClient @inlinable
    func store<Key, Value>(in type: [Key: Value].Type = [Key: Value].self) async rethrows -> [Key: Value] where Element == (Key, Value) {
        var result: [Key: Value] = [:]
        
        for try await (key, value) in self {
            result.insertOrFailOnDuplicate(key: key, value: value)
        }
        
        return result
        
        
    }
    
    @_alwaysEmitIntoClient @inlinable
    func store<Key, Value>(
        in type: [Key: Value].Type = [Key: Value].self,
        uniquingKeysWith: (Value, Value) -> Value
    ) async rethrows -> [Key: Value] where Element == (Key, Value) {
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
    
    @_alwaysEmitIntoClient @inlinable
    func compact<Wrapped>() -> AsyncCompactMapSequence<Self, Wrapped> where Element == Wrapped? {
        compactMap { element in element }
    }
    
    @_alwaysEmitIntoClient @inlinable
    func flatten<InnerElement>() -> AsyncThrowingFlatMapSequence<Self, Self.Element> where Element: AsyncSequence, Element.Element == InnerElement {
        flatMap { element in element }
    }
    
    @available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
    @_alwaysEmitIntoClient @inlinable
    func flatten<InnerElement>() -> AsyncFlatMapSequence<Self, Self.Element> where Element: AsyncSequence, Element.Element == InnerElement, Element.Failure == Failure {
        flatMap { element in element }
    }
    
    @_alwaysEmitIntoClient @inlinable
    func flatten<InnerElement>() -> AsyncFlatMapSequence<Self, SequenceAsyncWrapper<Self.Element>> where Element: Sequence, Element.Element == InnerElement {
        flatMap { element in element.async }
    }
    
    @_alwaysEmitIntoClient @inlinable
    func flatMap<R, InnerElement>(_ transform: @escaping @Sendable (Element) async throws -> R) -> AsyncFlatMapSequence<AsyncThrowingMapSequence<Self, R>, SequenceAsyncWrapper<R>> where R: Sequence, R.Element == InnerElement {
        map(transform)
            .flatten()
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
    
    @_alwaysEmitIntoClient @inlinable
    func appending(
        _ element: Element
    ) -> AsyncLazyInsertedSequence<SequenceAsyncWrapper<CollectionOfOne<Element>>, Self> {
        appending(contentsOf: CollectionOfOne(element).async)
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
    
    @_alwaysEmitIntoClient @inlinable
    func prepending(
        _ element: Element
    ) -> AsyncLazyInsertedSequence<Self, SequenceAsyncWrapper<CollectionOfOne<Element>>> {
        prepending(contentsOf: CollectionOfOne(element).async)
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
    
    @_alwaysEmitIntoClient @inlinable
    func inserting(
        _ element: Element,
        at index: Int
    ) -> AsyncLazyInsertedSequence<Self, SequenceAsyncWrapper<CollectionOfOne<Element>>> {
        inserting(contentsOf: CollectionOfOne(element).async, at: index)
    }
    
    @_alwaysEmitIntoClient @inlinable
    func removing<Indices: Sequence>(at indices: Indices) -> AsyncMapSequence<AsyncFilterSequence<AsyncEnumeratedSequence<Self>>, Self.Element> where Indices.Element == Int {
        let indices = indices.store(in: Array.self)

        return enumerated()
            .removingAll { index, _ in indices.contains(index) }
            .map(\.element)
    }
    
    @_alwaysEmitIntoClient @inlinable
    func removing(at index: Int) -> AsyncMapSequence<AsyncFilterSequence<AsyncEnumeratedSequence<Self>>, Self.Element> {
        removing(at: [index])
    }
    
    @_alwaysEmitIntoClient @inlinable
    func removingAll(
        where condition: @escaping @Sendable (Element) -> Bool
    ) -> AsyncFilterSequence<Self> {
        filter { element in !condition(element) }
    }
    
    @_alwaysEmitIntoClient @inlinable
    func removingAll<Elements: Sequence>(
        of elementsToRemove: Elements,
        by compare: @escaping @Sendable (Element, Element) -> Bool
    ) -> AsyncFilterSequence<Self> where Element: Sendable, Elements.Element == Element {
        let elementsToRemove = elementsToRemove.store(in: Array.self)

        return removingAll { element in
            elementsToRemove.contains(element, by: compare)
        }
    }
    
    @_alwaysEmitIntoClient @inlinable
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
    
    @_alwaysEmitIntoClient @inlinable
    func cartesianProduct<Other: AsyncSequence & Sendable>(with other: Other) -> AsyncThrowingFlatMapSequence<Self, AsyncMapSequence<Other, (Self.Element, Other.Element)>> where Element: Sendable, Other.Element: Sendable {
        flatMap { element in
            other
                .map { otherElement in
                    (element, otherElement)
                }
        }
    }
    
    @_alwaysEmitIntoClient @inlinable
    func first() async rethrows -> Element? {
        for try await element in self {
            return element
        }
        
        return nil
    }
    
    @_alwaysEmitIntoClient @inlinable
    func last() async rethrows -> Element? {
        var result: Element? = nil

        for try await element in self {
            result = element
        }

        return result
    }
    
    @_alwaysEmitIntoClient @inlinable
    func count() async rethrows -> Int {
        try await reduce(0) { count, _ in count + 1 }
    }
    
    @_alwaysEmitIntoClient @inlinable
    func contains(atLeast count: Int) async rethrows -> Bool {
        try await prefix(count).count() == count
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence where Element: Equatable {
    @_alwaysEmitIntoClient @inlinable
    func removingAll<Elements: Sequence>(
        of elementsToRemove: Elements
    ) -> AsyncFilterSequence<Self> where Element: Sendable, Elements.Element == Element {
        removingAll(of: elementsToRemove) { lhs, rhs in lhs == rhs }
    }
    
    @_alwaysEmitIntoClient @inlinable
    func removingAll(
        of elementToRemove: Element
    ) -> AsyncFilterSequence<Self> where Element: Sendable {
        removingAll(of: elementToRemove) { lhs, rhs in lhs == rhs }
    }
    
    @_alwaysEmitIntoClient @inlinable
    func removingDuplicates() -> AsyncRemoveDuplicatesSequence<Self> {
        removingDuplicates { lhs, rhs in lhs == rhs }
    }
}
