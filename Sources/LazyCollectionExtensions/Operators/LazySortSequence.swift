public protocol SortCompare<Element> {
    associatedtype Element
    
    func callAsFunction(_ lhs: Element, _ rhs: Element) -> Bool
}

public struct NonSendableSortCompare<Element>: SortCompare {
    public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Bool {
        _closure(lhs, rhs)
    }
    
    let _closure: (Element, Element) -> Bool
}

public struct SendableSortCompare<Element>: SortCompare, Sendable {
    public func callAsFunction(_ lhs: Element, _ rhs: Element) -> Bool {
        _closure(lhs, rhs)
    }
    
    let _closure: @Sendable (Element, Element) -> Bool
}

public struct LazySortSequence<
    Base: Sequence,
    Compare: SortCompare<Base.Element>
>: LazySequenceProtocol {
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Base.Element? {
            guard index < elements.count else {
                return nil
            }
            
            defer { index += 1 }
            
            for i in (index + 1)..<elements.count {
                if compare(elements[i], elements[index]) {
                    elements.swapAt(index, i)
                }
            }
            
            return elements[index]
        }
 
        var elements: [Base.Element]
        let compare: Compare
        var index = 0
    }
    
    public func makeIterator() -> Iterator {
        .init(
            elements: .init(base),
            compare: compare
        )
    }
    
    let base: Base
    let compare: Compare
}

extension LazySortSequence: Sendable where Base: Sendable, Compare: Sendable {}

public extension LazySequenceProtocol {
    /// Sorts the sequence lazily, so that only the elements actually reached during iteration are tested and put in the correct order.  Lazy sorting can be more or less efficient than a full eager sort depending on the use case.  The complexity of lazy sorting is O(n \* m), where n is the number of elements in the sequence, and m is the number of elements that are iterated over.  If only a few elements are needed, then lazy sorting is faster than full sorting.  But if all or close to all of the elements in the sequence are needed, then lazy sorting is slower than full sorting, because it will approach O(n^2) where eager sorting is O(n \* log(n)).  So lazy sorting is useful when it is composed with `prefix` operators to, for example, find the m smallest elements in a sequence.  If you only need the *first* smallest element, then the `min` function is better because it avoids allocating an array to store the partially sorted results (this is only necessary if more than one element needs to be ordered correctly).
    func lazySorted(by areInIncreasingOrder: @escaping (Element, Element) -> Bool) -> LazySortSequence<Elements, NonSendableSortCompare<Element>> {
        .init(
            base: elements,
            compare: .init(_closure: areInIncreasingOrder)
        )
    }
    
    func lazySortedSendable(by areInIncreasingOrder: @escaping @Sendable (Element, Element) -> Bool) -> LazySortSequence<Elements, SendableSortCompare<Element>> {
        .init(
            base: elements,
            compare: .init(_closure: areInIncreasingOrder)
        )
    }
}

public extension LazySequenceProtocol where Element: Comparable {
    func lazySorted() -> LazySortSequence<Elements, SendableSortCompare<Element>> {
        lazySortedSendable { $0 < $1 }
    }
}
