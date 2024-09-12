import Foundation
import OptionalExtensions

public struct InvalidHexCharacter: LocalizedError {
    let character: Character
    
    public var errorDescription: String? {
        "\(character) is not a valid hex character"
    }
}

public struct InvalidHexByte: LocalizedError {
    let string: String
    
    static func invalidCount(string: String) -> Self {
        .init(string: string, description: "Must contain exactly two characters")
    }
    
    static func invalidCharacter(string: String) -> Self {
        .init(string: string, description: "Not valid hex characters")
    }
    
    public var errorDescription: String? {
        "\(string) is not a valid hex byte: \(description)"
    }
    
    private let description: String
}

public struct InvalidHexString: LocalizedError {
    let string: String
    
    static func invalidCount(string: String) -> Self {
        .init(string: string, description: "Must contain exactly a multiple of two characters")
    }
    
    static func invalidCharacter(string: String) -> Self {
        .init(string: string, description: "Not valid hex characters")
    }
    
    public var errorDescription: String? {
        "\(string) is not a valid hex byte: \(description)"
    }
    
    private let description: String
}

public extension UInt8 {
    init(hexCharacter: Character) throws {
        self = switch hexCharacter.lowercased() {
            case "0": 0x0
            case "1": 0x1
            case "2": 0x2
            case "3": 0x3
            case "4": 0x4
            case "5": 0x5
            case "6": 0x6
            case "7": 0x7
            case "8": 0x8
            case "9": 0x9
            case "a": 0xa
            case "b": 0xb
            case "c": 0xc
            case "d": 0xd
            case "e": 0xe
            case "f": 0xf
            default: throw InvalidHexCharacter(character: hexCharacter)
        }
    }
    
    init(hexCharacters: (Character, Character)) throws {
        let (mostSignificantNibble, leastSignificantNibble): (UInt8, UInt8)
        
        do {
            mostSignificantNibble = try UInt8(hexCharacter: hexCharacters.0)
            leastSignificantNibble = try UInt8(hexCharacter: hexCharacters.1)
        } catch {
            throw InvalidHexByte.invalidCharacter(string: "\(hexCharacters.0)\(hexCharacters.1)")
        }
        
        self = mostSignificantNibble << 4 + leastSignificantNibble
    }
    
    var hexCharacters: (Character, Character) {
        ((self >> 4).hexCharacterOfFirstNibble, hexCharacterOfFirstNibble)
    }
    
    var hexDescription: String {
        let characters = hexCharacters
        
        return "\(characters.0)\(characters.1)"
    }
    
    private var hexCharacterOfFirstNibble: Character {
        switch (self & (1 << 4)) {
            case 0x0: "0"
            case 0x1: "1"
            case 0x2: "2"
            case 0x3: "3"
            case 0x4: "4"
            case 0x5: "5"
            case 0x6: "6"
            case 0x7: "7"
            case 0x8: "8"
            case 0x9: "9"
            case 0xa: "a"
            case 0xb: "b"
            case 0xc: "c"
            case 0xd: "d"
            case 0xe: "e"
            default: "f"
        }
    }
}

public struct HexByteFormat: ParseableFormatStyle {
    public struct ParseStrategy: Foundation.ParseStrategy {
        public func parse(_ value: String) throws -> UInt8 {
            let characters = value.store(in: Array.self)
            
            guard characters.count == 2 else {
                throw InvalidHexByte.invalidCount(string: value)
            }
            
            return try .init(hexCharacters:
                (characters[0], characters[1])
            )
        }
    }
    
    public var parseStrategy: ParseStrategy { .init() }
    
    public func format(_ value: UInt8) -> String {
        value.hexDescription
    }
}

public struct HexDataFormat<FormatInput: Sequence<UInt8>>: FormatStyle {
    public func format(_ value: FormatInput) -> String {
        .init(value.flatMap(Self.byteFormat.format))
    }
    
    private static var byteFormat: HexByteFormat { HexByteFormat() }
}

extension HexDataFormat: ParseableFormatStyle where FormatInput: RangeReplaceableCollection {
    public struct ParseStrategy<FormatOuput: Sequence<Character>>: Foundation.ParseStrategy {
        public func parse(_ value: FormatOuput) throws -> FormatInput {
            var result = FormatInput()
            
            var first: Character?
            
            for character in value {
                if let firstCharacter = first {
                    do {
                        let byte = try UInt8(hexCharacters:
                            (firstCharacter, character)
                        )
                        
                        result.append(byte)
                    } catch {
                        throw InvalidHexString.invalidCharacter(string: String(value))
                    }
                    
                    first = nil
                } else {
                    first = character
                }
            }
            
            if first != nil {
                throw InvalidHexString.invalidCount(string: String(value))
            }
            
            return result
        }

        private static var byteStrategy: HexByteFormat.ParseStrategy { .init() }
    }
    
    public var parseStrategy: ParseStrategy<String> { .init() }
}

public extension Sequence<UInt8> {
    func string(encoding: String.Encoding) -> String? {
        .init(data: .init(self), encoding: encoding)
    }
    
    var hexDescription: String {
        HexDataFormat().format(self)
    }
}

public extension RangeReplaceableCollection<UInt8> {
    init(hexString: some Sequence<Character>) throws {
        self = try HexDataFormat.ParseStrategy().parse(hexString)
    }
}

public extension Sequence<Character> {
    var hexData: [UInt8] {
        get throws {
            try hexData(in: [UInt8].self)
        }
    }
    
    func hexData<R: RangeReplaceableCollection<UInt8>>(in type: R.Type) throws -> R {
        try .init(hexString: self)
    }
}
