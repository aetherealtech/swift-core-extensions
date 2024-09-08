public extension Set {
    mutating func removeAll<S: Sequence<Element>>(of other: S) {
        for element in other {
            remove(element)
        }
    }
    
    func removingAll<S: Sequence>(of other: S) -> Self where S.Element == Element {
        var result = self
        result.removeAll(of: other)
        return result
    }
}
