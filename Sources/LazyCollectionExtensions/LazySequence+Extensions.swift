import CollectionExtensions

public extension LazySequenceProtocol {
    func compact<Wrapped>() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Elements, Element>>, Wrapped> where Element == Wrapped? {
        compactMap { element in element }
    }
    
    func flatten<InnerElement>() -> LazySequence<FlattenSequence<LazyMapSequence<Elements, LazySequence<Element>>>> where Element: Sequence, Element.Element == InnerElement {
        flatMap { element in element.lazy }
    }
    
    func appending<Elements: Sequence<Element>>(
        contentsOf elementsToAppend: Elements
    ) -> LazyInsertedSequence<Elements, Self.Elements> {
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
    
    func prepending<Elements: Sequence<Element>>(
        contentsOf elementsToAppend: Elements
    ) -> LazyInsertedSequence<Self.Elements, Elements> {
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
    
    func inserting<Elements: Sequence<Element>>(
        contentsOf elementsToAppend: Elements,
        at index: Int
    ) -> LazyInsertedSequence<Self.Elements, Elements> {
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
    
    func removing<Indices: Sequence<Int>>(at indices: Indices) -> LazyMapSequence<LazyFilterSequence<EnumeratedSequence<Self>>, Element> {
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
    
    func removingAll<Elements: Sequence<Element>>(
        of elementsToRemove: Elements,
        by compare: @escaping (Element, Element) -> Bool
    ) -> LazyFilterSequence<Self.Elements> {
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

public extension LazySequenceProtocol {
    func cartesianProduct<each Others: Sequence>(
        with others: repeat each Others
    ) -> LazyMapSequence<LazySequence<AnySequence<[Any]>>.Elements, (Element, repeat (each Others).Element)> {
        LazySequences.cartesianProduct(self, repeat each others)
    }
    
    func zip<each Others: Sequence>(
        with others: repeat each Others
    ) -> LazyMapSequence<LazySequence<AnySequence<[Any]>>.Elements, (Element, repeat (each Others).Element)> {
        LazySequences.zip(self, repeat each others)
    }
}

private func arrayToTuple<each Ts>(_ values: some Sequence) -> (repeat each Ts) {
    var iterator = values.makeIterator()
    
    return (repeat iterator.next() as! each Ts)
}

public enum LazySequences {
    static func cartesianProduct<each S: Sequence>(
        _ sequences: repeat each S
    ) -> LazyMapSequence<LazySequence<AnySequence<[Any]>>.Elements, (repeat (each S).Element)> {
        var erasedSequences = [any Sequence]()
        
        repeat (erasedSequences.append(each sequences))
        
        let erasedResult = cartesianProduct(erasedSequences)
        
        return erasedResult
            .lazy
            .map { erasedValue in arrayToTuple(erasedValue) }
    }
    
    static func zip<each S: Sequence>(
        _ sequences: repeat each S
    ) -> LazyMapSequence<LazySequence<AnySequence<[Any]>>.Elements, (repeat (each S).Element)> {
        var erasedSequences = [any Sequence]()
        
        repeat (erasedSequences.append(each sequences))
        
        let erasedResult = zip(erasedSequences)
        
        return erasedResult
            .lazy
            .map { erasedValue in arrayToTuple(erasedValue) }
    }
    
    private static func cartesianProduct(
        _ sequences: [any Sequence]
    ) -> AnySequence<[Any]> {
        guard !sequences.isEmpty else {
            return [].erase()
        }
        
        var sequences = sequences
        
        var result = sequences
            .removeFirst()
            .buffered()
            .lazy
            .map { [$0] }
            .erase()
        
        for sequence in sequences {
            let sequence = sequence
                .buffered()
            
            result = result
                .lazy
                .flatMap { element in
                    sequence
                        .lazy
                        .map { element.appending($0) }
                }
                .erase()
        }
        
        return result
    }
    
    private struct LazyZipSequence<Base1: Sequence, Base2: Sequence> : LazySequenceProtocol {
        struct Iterator: IteratorProtocol {
            mutating func next() -> (Base1.Element, Base2.Element)? {
                guard let first = base1.next(),
                      let second = base2.next() else {
                    return nil
                }
                
                return (first, second)
            }
            
            var base1: Base1.Iterator
            var base2: Base2.Iterator
        }
        
        func makeIterator() -> Iterator {
            .init(
                base1: base1.makeIterator(),
                base2: base2.makeIterator()
            )
        }
        
        let base1: Base1
        let base2: Base2
    }
    
    private static func zip(
        _ sequences: [any Sequence]
    ) -> AnySequence<[Any]> {
        guard !sequences.isEmpty else {
            return [].erase()
        }
        
        var sequences = sequences
        
        var result = sequences
            .removeFirst()
            .fullyErased()
            .lazy
            .map { [$0] }
            .erase()
        
    
        for sequence in sequences {
            result = LazyZipSequence(base1: result, base2: sequence.fullyErased())
                .map { current, next in
                    current.appending(next)
                }
                .erase()
        }
        
        return result
    }
}

private final class BufferedSequence<Base: Sequence>: Sequence {
    struct Iterator: IteratorProtocol {
        mutating func next() -> Base.Element? {
            if index < sequence.buffer.count {
                let result = sequence.buffer[index]
                index += 1
                return result
            } else if let next = sequence.iterator.next() {
                sequence.buffer.append(next)
                index += 1
                return next
            } else {
                return nil
            }
        }
        
        let sequence: BufferedSequence
        var index = 0
    }
    
    init(base: Base) {
        iterator = base.makeIterator()
    }
    
    func makeIterator() -> Iterator {
        .init(sequence: self)
    }
    
    private var buffer: [Base.Element] = []
    private var iterator: Base.Iterator
}

private extension Sequence {
    func buffered() -> AnySequence<Any> {
        if let collection = self as? any Collection {
            return collection.fullyErased()
        } else {
            return BufferedSequence(base: self).fullyErased()
        }
    }
}

