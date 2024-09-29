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

// These crash, likely to be same as this issue: https://github.com/swiftlang/swift/issues/68698

//public extension AsyncSequence {
//    func cartesianProduct<each Others: AsyncSequence>(
//        with others: repeat each Others
//    ) -> AsyncThrowingMapSequence<AnyAsyncSequence<AnyAsyncSequence<Any, any Error>, any Error>, (Element, repeat (each Others).Element)> {
//        AsyncSequences.cartesianProduct(self, repeat each others)
//    }
//    
//    func zip<each Others: AsyncSequence>(
//        with others: repeat each Others
//    ) -> AsyncThrowingMapSequence<AnyAsyncSequence<AnyAsyncSequence<Any, any Error>, any Error>, (Element, repeat (each Others).Element)> {
//        AsyncSequences.zip(self, repeat each others)
//    }
//}
//
//@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//private func arrayToTuple<each Ts>(_ values: some AsyncSequence) async rethrows -> (repeat each Ts) {
//    var iterator = values.makeAsyncIterator()
//    
//    return (repeat try await iterator.next() as! each Ts)
//}
//
//@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
//public enum AsyncSequences {
//    static func cartesianProduct<each S: AsyncSequence>(
//        _ sequences: repeat each S
//    ) -> AsyncThrowingMapSequence<AnyAsyncSequence<AnyAsyncSequence<Any, any Error>, any Error>, (repeat (each S).Element)> {
//        var erasedSequences = [any AsyncSequence]()
//        
//        repeat (erasedSequences.append(each sequences))
//        
//        let erasedResult = cartesianProduct(erasedSequences)
//        
//        return erasedResult
//            .map { erasedValue in
//                try await arrayToTuple(erasedValue)
//            }
//    }
//    
//    static func zip<each S: AsyncSequence>(
//        _ sequences: repeat each S
//    ) -> AsyncThrowingMapSequence<AnyAsyncSequence<AnyAsyncSequence<Any, any Error>, any Error>, (repeat (each S).Element)> {
//        var erasedSequences = [any AsyncSequence]()
//        
//        repeat (erasedSequences.append(each sequences))
//        
//        let erasedResult = zip(erasedSequences)
//        
//        return erasedResult
//            .map { erasedValue in try await arrayToTuple(erasedValue) }
//    }
//    
//    private static func cartesianProduct(
//        _ sequences: [any AsyncSequence]
//    ) -> AnyAsyncSequence<AnyAsyncSequence<Any, any Error>, any Error> {
//        guard !sequences.isEmpty else {
//            return EmptyCollection().async.erase()
//        }
//        
//        var sequences = sequences
//        
//        var result = sequences
//            .removeFirst()
//            .buffered()
//            .map { CollectionOfOne($0).async.erase() }
//            .erase()
//        
//        for sequence in sequences {
//            nonisolated(unsafe) let sequence = sequence
//                .buffered()
//            
//            result = result
//                .flatMap { (element: AnyAsyncSequence<Any, any Error>) in
//                    nonisolated(unsafe) let element = element
//                    
//                    return sequence
//                        .map { innerElement in element.appending(innerElement).erase() }
//                }
//                .erase()
//        }
//        
//        return result
//    }
//    
//    private struct AsyncZipSequence<Base1: AsyncSequence, Base2: AsyncSequence> : AsyncSequence {
//        struct AsyncIterator: AsyncIteratorProtocol {
//            mutating func next() async rethrows -> (Base1.Element, Base2.Element)? {
//                guard let first = try await base1.next(),
//                      let second = try await base2.next() else {
//                    return nil
//                }
//                
//                return (first, second)
//            }
//            
//            var base1: Base1.AsyncIterator
//            var base2: Base2.AsyncIterator
//        }
//        
//        func makeAsyncIterator() -> AsyncIterator {
//            .init(
//                base1: base1.makeAsyncIterator(),
//                base2: base2.makeAsyncIterator()
//            )
//        }
//        
//        let base1: Base1
//        let base2: Base2
//    }
//    
//    private static func zip(
//        _ sequences: [any AsyncSequence]
//    ) -> AnyAsyncSequence<AnyAsyncSequence<Any, any Error>, any Error> {
//        guard !sequences.isEmpty else {
//            return EmptyCollection().async.erase()
//        }
//        
//        var sequences = sequences
//        
//        var result = sequences
//            .removeFirst()
//            .fullyErased()
//            .map { CollectionOfOne($0).async.erase() }
//            .erase()
//        
//    
//        for sequence in sequences {
//            result = AsyncZipSequence(base1: result, base2: sequence.fullyErased())
//                .map { current, next in
//                    current.appending(next).erase()
//                }
//                .erase()
//        }
//        
//        return result
//    }
//}
