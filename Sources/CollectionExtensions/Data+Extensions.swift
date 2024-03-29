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

struct HexByteFormat: ParseableFormatStyle {
    struct ParseStrategy: Foundation.ParseStrategy {
        func parse(_ value: String) throws -> UInt8 {
            let characters = value.store(in: Array.self)
            
            guard characters.count == 2 else {
                throw InvalidHexByte.invalidCount(string: value)
            }
            
            
            let mostSignificantNibble = try (try? UInt8(hexCharacter: characters[0])).require(InvalidHexByte.invalidCharacter(string: value))
            let leastSignificantNibble = try (try? UInt8(hexCharacter: characters[1])).require(InvalidHexByte.invalidCharacter(string: value))
            
            return mostSignificantNibble << 4 + leastSignificantNibble
        }
    }
    
    var parseStrategy: ParseStrategy { .init() }
    
    func format(_ value: UInt8) -> String {
        .init(format: "%02x", value)
    }
}

struct HexDataFormat<FormatInput: Sequence>: FormatStyle where FormatInput.Element == UInt8 {
//    struct ParseStrategy: Foundation.ParseStrategy {
//        func parse(_ value: String) throws -> Data {
//            try .init(value.map(Self.byteStrategy.parse))
//        }
//
//        private static let byteStrategy = HexByteFormat.ParseStrategy()
//    }
//
//    var parseStrategy: ParseStrategy { .init() }
    
    func format(_ value: FormatInput) -> String {
        .init(value.flatMap(Self.byteFormat.format))
    }
    
    private static var byteFormat: HexByteFormat { HexByteFormat() }
}

extension UInt8 {
    var hexDescription: String {
        String(format: "%02x", self)
    }
}

public extension Sequence where Element == UInt8 {
    func string(encoding: String.Encoding) -> String? {
        .init(data: .init(self), encoding: encoding)
    }
    
    var hexDescription: String {
        HexDataFormat().format(self)
    }
}
