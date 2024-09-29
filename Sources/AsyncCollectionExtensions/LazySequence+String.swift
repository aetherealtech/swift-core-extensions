import Foundation

public enum StringParseError: LocalizedError {
    case invalidASCIICharacter
    case parseError
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence where Element == String.Element {
    var ascii: AsyncThrowingMapSequence<Self, UInt8> {
        map { character in
            try character.asciiValue.require(StringParseError.invalidASCIICharacter)
        }
    }
    
    var unicode: AsyncFlatMapSequence<Self, SequenceAsyncWrapper<String.UnicodeScalarView>> {
        flatMap { character in character.unicodeScalars.async }
    }
    
    var utf8: AsyncFlatMapSequence<Self, SequenceAsyncWrapper<String.UTF8View>> {
        flatMap { character in character.utf8.async }
    }
    
    var utf16: AsyncFlatMapSequence<Self, SequenceAsyncWrapper<String.UTF16View>> {
        flatMap { character in character.utf16.async }
    }
    
    var utf32: AsyncMapSequence<AsyncFlatMapSequence<Self, SequenceAsyncWrapper<String.UnicodeScalarView>>, UInt32> {
        self
            .unicode
            .map(\.value)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence {
    func string<Codec: UnicodeCodec>(
        codec: Codec.Type
    ) -> AsyncParsedUnicodeSequence<Codec, Self> where Element == Codec.CodeUnit {
        .init(source: self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence where Element == UInt8 {
    var asciiString: AsyncThrowingMapSequence<Self, Character> {
        map { byte in
            guard Unicode.ASCII.isASCII(byte) else {
                throw StringParseError.invalidASCIICharacter
            }
            
            return Character(Unicode.ASCII.decode(.init(byte)))
        }
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence where Element == UTF8.CodeUnit {
    var utf8String: AsyncParsedUnicodeSequence<UTF8, Self> {
        string(codec: UTF8.self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence where Element == UTF16.CodeUnit {
    var utf16String: AsyncParsedUnicodeSequence<UTF16, Self> {
        string(codec: UTF16.self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension AsyncSequence where Element == UTF32.CodeUnit {
    var utf32String: AsyncParsedUnicodeSequence<UTF32, Self> {
        string(codec: UTF32.self)
    }
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct AsyncParsedUnicodeSequence<Codec: UnicodeCodec, Source: AsyncSequence>: AsyncSequence where Source.Element == Codec.CodeUnit {
    public typealias Element = Result<UnicodeScalar, Error>
    
    public struct AsyncIterator: AsyncIteratorProtocol {
        public mutating func next() async rethrows -> Element? {
            var buffer: [Codec.CodeUnit] = []
            
            while true {
                guard let next = try await source.next() else {
                    return nil
                }
                
                buffer.append(next)
                
                var bufferIterator = buffer.makeIterator()
                let result = codec.decode(&bufferIterator)
                
                switch result {
                    case .emptyInput:
                        break
                    case let .scalarValue(scalar):
                        return .success(scalar)
                    case .error:
                        return .failure(StringParseError.parseError)
                }
            }
        }
        
        init(source: Source) {
            self.source = source.makeAsyncIterator()
        }
        
        private var source: Source.AsyncIterator
        private var codec = Codec()
    }
    
    public func makeAsyncIterator() -> AsyncIterator {
        .init(source: source)
    }
    
    init(source: Source) {
        self.source = source
    }
    
    private let source: Source
}
