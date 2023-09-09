import Foundation

public enum StringParseError: LocalizedError {
    case invalidASCIICharacter
    case parseError
}

public func ==<Element: Equatable>(lhs: some Collection<Element>, rhs: some Collection<Element>) -> Bool {
    lhs.elementsEqual(rhs)
}

public extension LazySequenceProtocol where Element == String.Element {
    var ascii: LazyMapSequence<Self.Elements, Result<UInt8, any Error>> {
        tryMap { character in
            try character.asciiValue.require(StringParseError.invalidASCIICharacter)
        }
    }
    
    var unicode: LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, String.UnicodeScalarView>>> {
        flatMap { character in character.unicodeScalars }
    }
    
    var utf8: LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, String.UTF8View>>> {
        flatMap { character in character.utf8 }
    }
    
    var utf16: LazySequence<FlattenSequence<LazyMapSequence<Self.Elements, String.UTF16View>>> {
        flatMap { character in character.utf16 }
    }
    
    var utf32: LazyMapSequence<FlattenSequence<LazyMapSequence<Self.Elements, String.UnicodeScalarView>>, UInt32> {
        unicode.map(\.value)
    }
}

public extension LazySequenceProtocol {
    func string<Codec: UnicodeCodec>(
        codec: Codec.Type
    ) -> ParsedUnicodeSequence<Codec, Self> where Element == Codec.CodeUnit {
        .init(source: self)
    }
}

public extension LazySequenceProtocol where Element == UInt8 {
    var asciiString: LazyMapSequence<Self.Elements, Result<Character, any Error>> {
        tryMap { byte in
            guard Unicode.ASCII.isASCII(byte) else {
                throw StringParseError.invalidASCIICharacter
            }
            
            return Character(Unicode.ASCII.decode(.init(byte)))
        }
    }
}

public extension LazySequenceProtocol where Element == UTF8.CodeUnit {
    var utf8String: ParsedUnicodeSequence<UTF8, Self> {
        string(codec: UTF8.self)
    }
}

public extension LazySequenceProtocol where Element == UTF16.CodeUnit {
    var utf16String: ParsedUnicodeSequence<UTF16, Self> {
        string(codec: UTF16.self)
    }
}

public extension LazySequenceProtocol where Element == UTF32.CodeUnit {
    var utf32String: ParsedUnicodeSequence<UTF32, Self> {
        string(codec: UTF32.self)
    }
}

public struct ParsedUnicodeSequence<Codec: UnicodeCodec, Source: Sequence<Codec.CodeUnit>>: Sequence {
    public typealias Element = Result<UnicodeScalar, Error>
    
    public struct Iterator: IteratorProtocol {
        public mutating func next() -> Element? {
            let result = codec.decode(&source)

            switch result {
                case .emptyInput:
                    return nil
                case let .scalarValue(scalar):
                    return .success(scalar)
                case .error:
                    return .failure(StringParseError.parseError)
            }
        }
        
        init(source: Source) {
            self.source = source.makeIterator()
        }
        
        private var source: Source.Iterator
        private var codec = Codec()
    }
    
    public func makeIterator() -> Iterator {
        .init(source: source)
    }
    
    init(source: Source) {
        self.source = source
    }
    
    private let source: Source
}
