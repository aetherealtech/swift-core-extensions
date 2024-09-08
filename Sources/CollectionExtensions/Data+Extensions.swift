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
        switch hexCharacter.lowercased() {
            case "0": self = 0x0
            case "1": self = 0x1
            case "2": self = 0x2
            case "3": self = 0x3
            case "4": self = 0x4
            case "5": self = 0x5
            case "6": self = 0x6
            case "7": self = 0x7
            case "8": self = 0x8
            case "9": self = 0x9
            case "a": self = 0xa
            case "b": self = 0xb
            case "c": self = 0xc
            case "d": self = 0xd
            case "e": self = 0xe
            case "f": self = 0xf
            default: throw InvalidHexCharacter(character: hexCharacter)
        }
    }
}

private func parseHex(
    character1: Character,
    character2: Character
) throws -> UInt8 {
    let (mostSignificantNibble, leastSignificantNibble): (UInt8, UInt8)
    
    do {
        mostSignificantNibble = try UInt8(hexCharacter: character1)
        leastSignificantNibble = try UInt8(hexCharacter: character2)
    } catch {
        throw InvalidHexByte.invalidCharacter(string: "\(character1)\(character2)")
    }
    
    return mostSignificantNibble << 4 + leastSignificantNibble
}

struct HexByteFormat: ParseableFormatStyle {
    struct ParseStrategy: Foundation.ParseStrategy {
        func parse(_ value: String) throws -> UInt8 {
            let characters = value.store(in: Array.self)
            
            guard characters.count == 2 else {
                throw InvalidHexByte.invalidCount(string: value)
            }
            
            return try parseHex(
                character1: characters[0],
                character2: characters[1]
            )
        }
    }
    
    var parseStrategy: ParseStrategy { .init() }
    
    func format(_ value: UInt8) -> String {
        .init(format: "%02x", value)
    }
}

struct HexDataFormat<FormatInput: Sequence<UInt8>>: FormatStyle {
    func format(_ value: FormatInput) -> String {
        .init(value.flatMap(Self.byteFormat.format))
    }
    
    private static var byteFormat: HexByteFormat { HexByteFormat() }
}

extension HexDataFormat: ParseableFormatStyle where FormatInput: RangeReplaceableCollection {
    struct ParseStrategy: Foundation.ParseStrategy {
        func parse(_ value: String) throws -> FormatInput {
            var result = FormatInput()
            
            var index = value.startIndex
            
            while index < value.endIndex {
                let character1 = value[index]
                value.formIndex(after: &index)
                
                if index == value.endIndex {
                    throw InvalidHexString.invalidCount(string: value)
                }
                
                let character2 = value[index]
                
                do {
                    let byte = try parseHex(
                        character1: character1,
                        character2: character2
                    )
                    
                    result.append(byte)
                } catch {
                    throw InvalidHexString.invalidCharacter(string: value)
                }
                
                value.formIndex(after: &index)
            }
            
            return result
        }

        private static var byteStrategy: HexByteFormat.ParseStrategy { .init() }
    }
    
    var parseStrategy: ParseStrategy { .init() }
}

extension UInt8 {
    var hexDescription: String {
        String(format: "%02x", self)
    }
}

public extension Sequence<UInt8> {
    func string(encoding: String.Encoding) -> String? {
        .init(data: .init(self), encoding: encoding)
    }
    
    var hexDescription: String {
        HexDataFormat().format(self)
    }
}
