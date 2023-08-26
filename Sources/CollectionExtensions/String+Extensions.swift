import CompareFunctions
import Foundation

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

public extension String {
    var nsRange: NSRange {
        .init(startIndex ..< endIndex, in: self)
    }
}

public extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

public extension StringProtocol {
    var embeddedAsLiteral: String {
        try! .init(data: JSONEncoder().encode(store(in: String.self)), encoding: .utf8)!
    }

    var extractedStringLiteral: String {
        get throws {
            try JSONDecoder().decode(String.self, from: data(using: .utf8)!)
        }
    }
}
