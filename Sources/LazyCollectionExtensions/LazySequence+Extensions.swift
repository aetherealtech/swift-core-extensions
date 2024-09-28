import CollectionExtensions

public extension LazySequenceProtocol {
    func compact<Wrapped>() -> LazyMapSequence<LazyFilterSequence<LazyMapSequence<Elements, Element>>, Wrapped> where Element == Wrapped? {
        compactMap { element in element }
    }
    
    func flatten<InnerElement>() -> LazySequence<FlattenSequence<LazyMapSequence<Elements, LazySequence<Element>>>> where Element: Sequence, Element.Element == InnerElement {
        flatMap { element in element.lazy }
    }
    
    func appending(
        _ element: Element
    ) -> LazyInsertedSequence<CollectionOfOne<Element>, Elements> {
        appending(contentsOf: .init(element))
    }
    
    func appending(
        _ element: Element,
        if condition: Bool
    ) -> LazyInsertedSequence<LazyIfElseSequence<CollectionOfOne<Element>, EmptyCollection<Element>>, Elements> {
        appending(
            contentsOf: .init(element),
            if: condition
        )
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
    
    func appending<Elements: Sequence<Element>>(
        contentsOf elementsToAppend: Elements,
        if condition: Bool
    ) -> LazyInsertedSequence<LazyIfElseSequence<Elements, EmptyCollection<Element>>, Self.Elements> {
        .init(
            source: condition ? .if(elementsToAppend) : .else(.init()),
            inserted: elements,
            insertAt: 0
        )
    }
    
    func prepending(
        _ element: Element
    ) -> LazyInsertedSequence<Elements, CollectionOfOne<Element>> {
        prepending(contentsOf: .init(element))
    }
    
    func prepending(
        _ element: Element,
        if condition: Bool
    ) -> LazyInsertedSequence<Self.Elements, LazyIfElseSequence<CollectionOfOne<Element>, EmptyCollection<Element>>> {
        inserting(
            element,
            at: 0,
            if: condition
        )
    }
    
    func prepending<Elements: Sequence<Element>>(
        contentsOf elementsToPrepend: Elements
    ) -> LazyInsertedSequence<Self.Elements, Elements> {
        .init(
            source: elements,
            inserted: elementsToPrepend,
            insertAt: 0
        )
    }
    
    func prepending<Elements: Sequence<Element>>(
        contentsOf elementsToPrepend: Elements,
        if condition: Bool
    ) -> LazyInsertedSequence<Self.Elements, LazyIfElseSequence<Elements, EmptyCollection<Element>>> {
        inserting(
            contentsOf: elementsToPrepend,
            at: 0,
            if: condition
        )
    }
    
    func inserting(
        _ element: Element,
        at index: Int
    ) -> LazyInsertedSequence<Elements, CollectionOfOne<Element>> {
        inserting(
            contentsOf: .init(element),
            at: index
        )
    }
    
    func inserting(
        _ element: Element,
        at index: Int,
        if condition: Bool
    ) -> LazyInsertedSequence<Elements, LazyIfElseSequence<CollectionOfOne<Element>, EmptyCollection<Element>>> {
        inserting(
            contentsOf: .init(element),
            at: index,
            if: condition
        )
    }

    func inserting<Elements: Sequence<Element>>(
        contentsOf elementsToInsert: Elements,
        at index: Int
    ) -> LazyInsertedSequence<Self.Elements, Elements> {
        .init(
            source: elements,
            inserted: elementsToInsert,
            insertAt: index
        )
    }
    
    func inserting<Elements: Sequence<Element>>(
        contentsOf elementsToInsert: Elements,
        at index: Int,
        if condition: Bool
    ) -> LazyInsertedSequence<Self.Elements, LazyIfElseSequence<Elements, EmptyCollection<Element>>> {
        .init(
            source: elements,
            inserted: condition ? .if(elementsToInsert) : .else(.init()),
            insertAt: index
        )
    }
    
    func filterIndices(
        _ condition: @escaping (Int) -> Bool
    ) -> LazyMapSequence<LazyFilterSequence<EnumeratedSequence<Self>>, Element> {
        return enumerated()
            .lazy
            .filter { condition($0.offset) }
            .map(\.element)
    }

    func removing(at indexToRemove: Int) -> LazyMapSequence<LazyFilterSequence<EnumeratedSequence<Self>>, Element> {
        enumerated()
            .lazy
            .removingAll { index, _ in index == indexToRemove }
            .map(\.element)
    }
    
    func removingWhereIndices(
        _ condition: @escaping (Int) -> Bool
    ) -> LazyMapSequence<LazyFilterSequence<EnumeratedSequence<Self>>, Element> {
        return enumerated()
            .lazy
            .removingAll { condition($0.offset) }
            .map(\.element)
    }
    
    func removing<Indices: Sequence<Int>>(at indices: Indices) -> LazyMapSequence<LazyFilterSequence<EnumeratedSequence<Self>>, Element> {
        let indices = indices.store(in: Array.self)
        
        return enumerated()
            .lazy
            .removingAll { index, _ in indices.contains(index) }
            .map(\.element)
    }
    
    func removingAll(
        where condition: @escaping (Element) -> Bool
    ) -> LazyFilterSequence<Elements> {
        filter { element in !condition(element) }
    }
    
    func removingAll(
        of elementToRemove: Element,
        by compare: @escaping (Element, Element) -> Bool
    ) -> LazyFilterSequence<Elements> {
        return removingAll { element in
            compare(element, elementToRemove)
        }
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

    func removingDuplicates(
        by compare: @escaping (Element, Element) -> Bool
    ) -> RemoveDuplicatesSequence<Elements, NonSendableDuplicateCompare<Element>> {
        .init(
            source: elements,
            compare: .init(_closure: compare)
        )
    }
    
    func removingDuplicatesSendable(
        by compare: @escaping @Sendable (Element, Element) -> Bool
    ) -> RemoveDuplicatesSequence<Elements, SendableDuplicateCompare<Element>> {
        .init(
            source: elements,
            compare: .init(_closure: compare)
        )
    }

    var last: Element? {
        var result: Element? = nil
        
        for element in self {
            result = element
        }
        
        return result
    }
    
    func count() -> Int {
        lazy
            .map { _ in 1 }
            .reduce(0, +)
    }
    
    func contains(atLeast count: Int) -> Bool {
        prefix(count).lazy.count() == count
    }
    
    func accumulate<R>(
        _ initialValue: R,
        _ accumulate: @escaping (R, Element) -> R
    ) -> LazyAccumulateSequence<Elements, NonSendableAcculuator<R, Element>> {
        .init(
            source: elements,
            initial: initialValue,
            accumulator: .init(_closure: accumulate)
        )
    }
    
    func accumulateSendable<R>(
        _ initialValue: R,
        _ accumulate: @escaping @Sendable (R, Element) -> R
    ) -> LazyAccumulateSequence<Elements, SendableAcculuator<R, Element>> {
        .init(
            source: elements,
            initial: initialValue,
            accumulator: .init(_closure: accumulate)
        )
    }
}

// As with `map`, some of these compile without the constraint.
public extension LazySequenceProtocol where Elements: Sendable {
    func compactMapSendable<Result>(_ transform: @escaping @Sendable (Element) -> Result?) -> LazySendableMapSequence<LazySendableFilterSequence<LazySendableMapSequence<Elements, Result?>>, Result> {
        mapSendable(transform)
            .filterSendable { $0 != nil }
            .mapSendable { $0.unsafelyUnwrapped }
    }
    
    func removingAllSendable(
        where condition: @escaping @Sendable (Element) -> Bool
    ) -> LazySendableFilterSequence<Elements> {
        filterSendable { element in !condition(element) }
    }
    
    func removingAllSendable(
        of elementToRemove: Element,
        by compare: @escaping @Sendable (Element, Element) -> Bool
    ) -> LazySendableFilterSequence<Elements> where Element: Sendable {
        return removingAllSendable { element in
            compare(element, elementToRemove)
        }
    }
    
    func removingAllSendable<Elements: Sequence<Element>>(
        of elementsToRemove: Elements,
        by compare: @escaping @Sendable (Element, Element) -> Bool
    ) -> LazySendableFilterSequence<Self.Elements> where Element: Sendable {
        let elementsToRemove = elementsToRemove.store(in: Array.self)
        
        return removingAllSendable { element in
            elementsToRemove.contains(element, by: compare)
        }
    }
}

public extension LazySequenceProtocol where Self: Sendable {
    func filterIndicesSendable(
        _ condition: @escaping @Sendable (Int) -> Bool
    ) -> LazySendableMapSequence<LazySendableFilterSequence<EnumeratedSequence<Self>>, Element> {
        return enumerated()
            .lazy
            .filterSendable { condition($0.offset) }
            .mapSendable(\.element)
    }
    
    func removingWhereIndicesSendable(
        _ condition: @escaping @Sendable (Int) -> Bool
    ) -> LazySendableMapSequence<LazySendableFilterSequence<EnumeratedSequence<Self>>, Element> {
        return enumerated()
            .lazy
            .removingAllSendable { condition($0.offset) }
            .mapSendable(\.element)
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

    func removingDuplicates() -> RemoveDuplicatesSequence<Elements, SendableDuplicateCompare<Element>> {
        removingDuplicatesSendable(by: { lhs, rhs in lhs == rhs })
    }
}

public extension LazySequenceProtocol {
    func cartesianProduct<each Others: Sequence>(
        with others: repeat each Others
    ) -> LazyMapSequence<AnySequence<AnySequence<Any>>, (Element, repeat (each Others).Element)> {
        LazySequences.cartesianProduct(self, repeat each others)
    }
    
    func zip<each Others: Sequence>(
        with others: repeat each Others
    ) -> LazyMapSequence<AnySequence<AnySequence<Any>>, (Element, repeat (each Others).Element)> {
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
    ) -> LazyMapSequence<AnySequence<AnySequence<Any>>, (repeat (each S).Element)> {
        var erasedSequences = [any Sequence]()
        
        repeat (erasedSequences.append(each sequences))
        
        let erasedResult = cartesianProduct(erasedSequences)
        
        return erasedResult
            .lazy
            .map { erasedValue in arrayToTuple(erasedValue) }
    }
    
    static func zip<each S: Sequence>(
        _ sequences: repeat each S
    ) -> LazyMapSequence<AnySequence<AnySequence<Any>>, (repeat (each S).Element)> {
        var erasedSequences = [any Sequence]()
        
        repeat (erasedSequences.append(each sequences))
        
        let erasedResult = zip(erasedSequences)
        
        return erasedResult
            .lazy
            .map { erasedValue in arrayToTuple(erasedValue) }
    }
    
    private static func cartesianProduct(
        _ sequences: [any Sequence]
    ) -> AnySequence<AnySequence<Any>> {
        guard !sequences.isEmpty else {
            return EmptyCollection().erase()
        }
        
        var sequences = sequences
        
        var result = sequences
            .removeFirst()
            .buffered()
            .lazy
            .map { CollectionOfOne($0).erase() }
            .erase()
        
        for sequence in sequences {
            let sequence = sequence
                .buffered()
            
            result = result
                .lazy
                .flatMap { (element: AnySequence<Any>) in
                    sequence
                        .lazy
                        .map { innerElement in element.lazy.appending(innerElement).erase() }
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
    ) -> AnySequence<AnySequence<Any>> {
        guard !sequences.isEmpty else {
            return EmptyCollection().erase()
        }
        
        var sequences = sequences
        
        var result = sequences
            .removeFirst()
            .fullyErased()
            .lazy
            .map { CollectionOfOne($0).erase() }
            .erase()
        
    
        for sequence in sequences {
            result = LazyZipSequence(base1: result, base2: sequence.fullyErased())
                .map { current, next in
                    current.lazy.appending(next).erase()
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

