import CollectionExtensions

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    func compact<Wrapped>() -> AsyncCompactMapSequence<Self, Wrapped> where Element == Wrapped? {
        compactMap { element in element }
    }

    func flatten<InnerElement>() -> AsyncFlatMapSequence<Self, Self.Element> where Element: AsyncSequence, Element.Element == InnerElement {
        flatMap { element in element }
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
        where condition: @escaping (Element) -> Bool
    ) -> AsyncFilterSequence<Self> {
        filter { element in !condition(element) }
    }

    func removingAll<Elements: Sequence>(
        of elementsToRemove: Elements,
        by compare: @escaping (Element, Element) -> Bool
    ) -> AsyncFilterSequence<Self> where Elements.Element == Element {
        let elementsToRemove = elementsToRemove.store(in: Array.self)

        return removingAll { element in
            elementsToRemove.contains(element, by: compare)
        }
    }

    func removingAll(
        of elementToRemove: Element,
        by compare: @escaping (Element, Element) -> Bool
    ) -> AsyncFilterSequence<Self> {
        removingAll { element in
            compare(element, elementToRemove)
        }
    }

    func removingDuplicates(
        by compare: @escaping (Element, Element) -> Bool
    ) -> AsyncFilterSequence<Self> {
        var checked = [Element]()

        return filter { element in
            if checked.contains(element, by: compare) {
                return false
            } else {
                checked.append(element)
                return true
            }
        }
    }

    func cartesianProduct<Other: AsyncSequence>(with other: Other) -> AsyncFlatMapSequence<Self, AsyncMapSequence<Other, (Self.Element, Other.Element)>> {
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
    ) -> AsyncFilterSequence<Self> where Elements.Element == Element {
        removingAll(of: elementsToRemove, by: ==)
    }

    func removingAll(
        of elementToRemove: Element
    ) -> AsyncFilterSequence<Self> {
        removingAll(of: elementToRemove, by: ==)
    }

    func removingDuplicates() -> AsyncFilterSequence<Self> {
        removingDuplicates(by: ==)
    }
}
