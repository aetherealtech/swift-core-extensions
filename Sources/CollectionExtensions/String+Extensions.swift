import CompareFunctions

public extension Sequence where Element == String.Element {
    func toString() -> String {
        .init(self)
    }
}

public extension Sequence where Element: StringProtocol {
    func joinedNonEmpty<Separator: StringProtocol>(separator: Separator) -> JoinedSequence<[Element]> {
        filter { element in !element.isEmpty }
            .joined(separator: separator)
    }
}

public extension Sequence {
    func alphabetized<Name: StringProtocol>(by name: (Element) -> Name) -> [(key: String, values: [Element])] {
        sorted(by: name)
            .grouped(by: { element in name(element).alphabeticPosition })
            .compactMap { key, value in key.map { key in (key: String(key), values: value) } }
            .sorted(by: \.key)
    }
}

public extension Sequence where Element == String {
    var alphabetized: [(key: String, values: [Element])] {
        let keypath: (Element) -> Element = \Element.self
        return alphabetized(by: keypath)
    }
}

public extension Collection where Element == String.Element {
    var alphabeticPosition: Element? {
        guard let first else { return nil }
        
        if first.isNumber {
            return "#"
        }
        
        return first
    }
}
