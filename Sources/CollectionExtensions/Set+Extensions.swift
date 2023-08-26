public extension Set {
    mutating func removeAll<S: Sequence>(of other: S) where S.Element == Element {
        for element in other {
            remove(element)
        }
    }
    
    func removingAll<S: Sequence>(of other: S) -> Self where S.Element == Element {
        immutable { result in
            result.removeAll(of: other)
        }
    }
}
