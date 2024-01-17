import CompareFunctions
import Foundation

public extension Sequence {
    func store<C: RangeReplaceableCollection>(in type: C.Type = C.self) -> C where C.Element == Element {
        .init(self)
    }
    
    func store(in type: Set<Element>.Type = Set.self) -> Set<Element> where Element: Hashable {
        .init(self)
    }
    
    func store<Key, Value>(in type: [Key: Value].Type = [Key: Value].self) -> [Key: Value] where Element == (Key, Value) {
        .init(uniqueKeysWithValues: self)
    }
    
    func store<Key, Value>(
        in type: [Key: Value].Type = [Key: Value].self,
        uniquingKeysWith: (Value, Value) -> Value
    ) -> [Key: Value] where Element == (Key, Value) {
        .init(
            self,
            uniquingKeysWith: uniquingKeysWith
        )
    }
    
    func compact<Wrapped>() -> [Wrapped] where Element == Wrapped? {
        compactMap { element in element }
    }
    
    func flatten<InnerElement>() -> [InnerElement] where Element: Sequence, Element.Element == InnerElement {
        flatMap { element in element }
    }
    
    func of<T>(type: T.Type) -> [T] {
        compactMap { element in element as? T }
    }
    
    func grouped<Key: Hashable>(by grouper: (Element) -> Key) -> [Key: [Element]] {
        .init(grouping: self, by: grouper)
    }

    func sorted(using compare: CompareFunction<Element>) -> [Element] {
        sorted(by: { lhs, rhs in compare(lhs, rhs) == .orderedAscending })
    }

    func sorted<R>(by transform: (Element) -> R, using compare: SimpleCompareFunction<R>) -> [Element] {
        sorted(by: { lhs, rhs in compare(transform(lhs), transform(rhs)) })
    }
    
    func sorted<R: Comparable>(by transform: (Element) -> R) -> [Element] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transform) }
    }
    
    func sorted<each Rs: Comparable>(by transforms: repeat (Element) -> each Rs) -> [Element] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: repeat each transforms) }
    }
    
    func sorted<R>(by transform: (Element) -> R, using compare: CompareFunction<R>) -> [Element] {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transform, using: compare) }
    }
    
    func sorted(using compares: CompareFunction<Element>...) -> [Element] {
        sorted(using: compares)
    }
    
    func sorted<Compares: Sequence>(using compares: Compares) -> [Element] where Compares.Element == CompareFunction<Element> {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, using: compares) }
    }
    
    func sorted<R: Comparable & Equatable>(by transforms: (Element) -> R...) -> [Element] {
        sorted(by: transforms)
    }
    
    func sorted<R: Comparable & Equatable, Transforms: Sequence>(by transforms: Transforms) -> [Element] where Transforms.Element == (Element) -> R {
        sorted { lhs, rhs in CompareFunctions.compare(lhs, rhs, by: transforms) }
    }
    
    func erase() -> AnySequence<Element> {
        .init(self)
    }
}
