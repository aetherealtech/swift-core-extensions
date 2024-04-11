import CollectionExtensions

public extension LazySequenceProtocol {
    func compact<Wrapped>() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Elements, Element>>, Wrapped> where Element == Wrapped? {
        compactMap { element in element }
    }
    
    func flatten<InnerElement>() -> LazySequence<FlattenSequence<LazyMapSequence<Elements, LazySequence<Element>>>> where Element: Sequence, Element.Element == InnerElement {
        flatMap { element in element.lazy }
    }

    func of<T>(type: T.Type) -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Elements, T?>>, T> {
        compactMap { element in element as? T }
    }
    
    func appending<Elements: Sequence>(
        contentsOf elementsToAppend: Elements
    ) -> LazyInsertedSequence<Elements, Self.Elements> where Elements.Element == Element {
        .init(
            source: elementsToAppend,
            inserted: elements,
            insertAt: 0
        )
    }
    
    func appending(
        _ element: Element
    ) -> LazyInsertedSequence<[Element], Elements> {
        appending(contentsOf: [element])
    }
    
    func prepending<Elements: Sequence>(
        contentsOf elementsToAppend: Elements
    ) -> LazyInsertedSequence<Self.Elements, Elements> where Elements.Element == Element {
        .init(
            source: elements,
            inserted: elementsToAppend,
            insertAt: 0
        )
    }
    
    func prepending(
        _ element: Element
    ) -> LazyInsertedSequence<Elements, [Element]> {
        prepending(contentsOf: [element])
    }
    
    func inserting<Elements: Sequence>(
        contentsOf elementsToAppend: Elements,
        at index: Int
    ) -> LazyInsertedSequence<Self.Elements, Elements> where Elements.Element == Element {
        .init(
            source: elements,
            inserted: elementsToAppend,
            insertAt: index
        )
    }
    
    func inserting(
        _ element: Element,
        at index: Int
    ) -> LazyInsertedSequence<Elements, [Element]> {
        inserting(contentsOf: [element], at: index)
    }
    
    func removing<Indices: Sequence>(at indices: Indices) -> LazyMapSequence<LazyFilterSequence<EnumeratedSequence<Self>>, Element> where Indices.Element == Int {
        let indices = indices.store(in: Array.self)
        
        return enumerated()
            .lazy
            .removingAll { index, _ in indices.contains(index) }
            .map(\.element)
    }
    
    func removing(at index: Int) -> LazyMapSequence<LazyFilterSequence<EnumeratedSequence<Self>>, Element> {
        removing(at: [index])
    }
    
    func removingAll(
        where condition: @escaping (Element) -> Bool
    ) -> LazyFilterSequence<Elements> {
        filter { element in !condition(element) }
    }
    
    func removingAll<Elements: Sequence>(
        of elementsToRemove: Elements,
        by compare: @escaping (Element, Element) -> Bool
    ) -> LazyFilterSequence<Self.Elements> where Elements.Element == Element {
        let elementsToRemove = elementsToRemove.store(in: Array.self)
        
        return removingAll { element in
            elementsToRemove.contains(element, by: compare)
        }
    }
    
    func removingAll(
        of elementToRemove: Element,
        by compare: @escaping (Element, Element) -> Bool
    ) -> LazyFilterSequence<Elements> {
        return removingAll { element in
            compare(element, elementToRemove)
        }
    }

    func removingDuplicates(
        by compare: @escaping (Element, Element) -> Bool
    ) -> LazyFilterSequence<Elements> {
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
    
    func cartesianProduct<Other: Sequence>(with other: Other) -> LazySequence<FlattenSequence<LazyMapSequence<Elements, LazyMapSequence<Other, (Element, Other.Element)>>>> {
        flatMap { element in
            other
                .lazy
                .map { otherElement in
                    (element, otherElement)
                }
        }
    }

    var last: Element? {
        var result: Element? = nil
        
        for element in self {
            result = element
        }
        
        return result
    }
    
    func count() -> Int {
        reduce(0) { count, _ in count + 1 }
    }
    
    func contains(atLeast count: Int) -> Bool {
        prefix(count).lazy.count() == count
    }
    
    func accumulate<R>(_ initialValue: R, _ accumulate: @escaping (R, Element) -> R) -> LazyMapSequence<Elements, R> {
        var accumulated = initialValue
        
        return map { element in
            accumulated = accumulate(accumulated, element)
            return accumulated
        }
    }
}

public extension LazySequenceProtocol where Element: Equatable {
    func removingAll<Elements: Sequence>(
        of elementsToRemove: Elements
    ) -> LazyFilterSequence<Self.Elements> where Elements.Element == Element {
        removingAll(of: elementsToRemove, by: ==)
    }
    
    func removingAll(
        of elementToRemove: Element
    ) -> LazyFilterSequence<Elements> {
        removingAll(of: elementToRemove, by: ==)
    }

    func removingDuplicates() -> LazyFilterSequence<Elements> {
        removingDuplicates(by: ==)
    }
}
