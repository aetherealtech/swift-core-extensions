import Assertions
import XCTest

@testable import LazyCollectionExtensions

final class LazySequenceStringTests: XCTestCase {
    func testASCIISucceeds() throws {
        let input = "Hello World"
        
        let expectedResult = [
            ("H" as Character).asciiValue!,
            ("e" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("o" as Character).asciiValue!,
            (" " as Character).asciiValue!,
            ("W" as Character).asciiValue!,
            ("o" as Character).asciiValue!,
            ("r" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("d" as Character).asciiValue!,
        ]
        
        let result = try input
            .lazy
            .ascii
            .tryStore(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testASCIIFails() throws {
        let input = "Hellö World"

        let result = input
            .lazy
            .ascii
        
        try assertThrowsError {
            try result
                .tryStore(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .invalidASCIICharacter)
        }
    }
    
    func testUTF8() throws {
        let input = "He 𠁚 llö ࢢ ωorld 𠁄"

        let expectedResult = [
            "H".utf8,
            "e".utf8,
            " ".utf8,
            "𠁚".utf8,
            " ".utf8,
            "l".utf8,
            "l".utf8,
            "ö".utf8,
            " ".utf8,
            "ࢢ".utf8,
            " ".utf8,
            "ω".utf8,
            "o".utf8,
            "r".utf8,
            "l".utf8,
            "d".utf8,
            " ".utf8,
            "𠁄".utf8,
        ].flatMap { $0 }
        
        let result = input
            .lazy
            .utf8
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testUTF16() throws {
        let input = "He 𠁚 llö ࢢ ωorld 𠁄"

        let expectedResult = [
            "H".utf16,
            "e".utf16,
            " ".utf16,
            "𠁚".utf16,
            " ".utf16,
            "l".utf16,
            "l".utf16,
            "ö".utf16,
            " ".utf16,
            "ࢢ".utf16,
            " ".utf16,
            "ω".utf16,
            "o".utf16,
            "r".utf16,
            "l".utf16,
            "d".utf16,
            " ".utf16,
            "𠁄".utf16,
        ].flatMap { $0 }
        
        let result = input
            .lazy
            .utf16
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testUTF32() throws {
        let input = "He 𠁚 llö ࢢ ωorld 𠁄"

        let expectedResult = [
            "H".unicodeScalars,
            "e".unicodeScalars,
            " ".unicodeScalars,
            "𠁚".unicodeScalars,
            " ".unicodeScalars,
            "l".unicodeScalars,
            "l".unicodeScalars,
            "ö".unicodeScalars,
            " ".unicodeScalars,
            "ࢢ".unicodeScalars,
            " ".unicodeScalars,
            "ω".unicodeScalars,
            "o".unicodeScalars,
            "r".unicodeScalars,
            "l".unicodeScalars,
            "d".unicodeScalars,
            " ".unicodeScalars,
            "𠁄".unicodeScalars,
        ].flatMap { $0.map(\.value) }
        
        let result = input
            .lazy
            .utf32
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseASCIISucceeds() throws {
        let input = [
            ("H" as Character).asciiValue!,
            ("e" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("o" as Character).asciiValue!,
            (" " as Character).asciiValue!,
            ("W" as Character).asciiValue!,
            ("o" as Character).asciiValue!,
            ("r" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("d" as Character).asciiValue!,
        ]
        
        let expectedResult = "Hello World"

        let result = try input
            .lazy
            .asciiString
            .tryStore(in: String.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseASCIIFails() throws {
        let input = [
            ("H" as Character).asciiValue!,
            ("e" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("ö" as Character).utf8.first!,
            (" " as Character).asciiValue!,
            ("W" as Character).asciiValue!,
            ("o" as Character).asciiValue!,
            ("r" as Character).asciiValue!,
            ("l" as Character).asciiValue!,
            ("d" as Character).asciiValue!,
        ]
        
        let result = input
            .lazy
            .asciiString
        
        try assertThrowsError {
            try result
                .tryStore(in: String.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .invalidASCIICharacter)
        }
    }
    
    func testParseUTF8Succeeds() throws {
        let input = [
            "H".utf8,
            "e".utf8,
            " ".utf8,
            "𠁚".utf8,
            " ".utf8,
            "l".utf8,
            "l".utf8,
            "ö".utf8,
            " ".utf8,
            "ࢢ".utf8,
            " ".utf8,
            "ω".utf8,
            "o".utf8,
            "r".utf8,
            "l".utf8,
            "d".utf8,
            " ".utf8,
            "𠁄".utf8,
        ].flatMap { $0 }
        
        let expectedResult = "He 𠁚 llö ࢢ ωorld 𠁄"
        
        let result = try input
            .lazy
            .utf8String
            .tryStore(in: String.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseUTF8Fails() throws {
        let input = [
            "H".utf8,
            "e".utf8,
            " ".utf8,
            "𠁚".utf8,
            " ".utf8,
            "l".utf8,
            "l".utf8,
            "ö".utf8,
            " ".utf8,
            "ࢢ".utf8,
            " ".utf8,
            "ω".utf8,
            "o".utf8,
            "r".utf8,
            "l".utf8,
            "d".utf8,
            " ".utf8,
            "𠁄".utf8,
        ].flatMap { [$0.first!] }
                
        let result = input
            .lazy
            .utf8String
        
        try assertThrowsError {
            try result
                .tryStore(in: String.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .parseError)
        }
    }
    
    func testParseUTF16Succeeds() throws {
        let input = [
            "H".utf16,
            "e".utf16,
            " ".utf16,
            "𠁚".utf16,
            " ".utf16,
            "l".utf16,
            "l".utf16,
            "ö".utf16,
            " ".utf16,
            "ࢢ".utf16,
            " ".utf16,
            "ω".utf16,
            "o".utf16,
            "r".utf16,
            "l".utf16,
            "d".utf16,
            " ".utf16,
            "𠁄".utf16,
        ].flatMap { $0 }
        
        let expectedResult = "He 𠁚 llö ࢢ ωorld 𠁄"
        
        let result = try input
            .lazy
            .utf16String
            .tryStore(in: String.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseUTF16Fails() throws {
        let input = [
            "H".utf16,
            "e".utf16,
            " ".utf16,
            "𠁚".utf16,
            " ".utf16,
            "l".utf16,
            "l".utf16,
            "ö".utf16,
            " ".utf16,
            "ࢢ".utf16,
            " ".utf16,
            "ω".utf16,
            "o".utf16,
            "r".utf16,
            "l".utf16,
            "d".utf16,
            " ".utf16,
            "𠁄".utf16,
        ].flatMap { [$0.first!] }
                
        let result = input
            .lazy
            .utf16String
        
        try assertThrowsError {
            try result
                .tryStore(in: String.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .parseError)
        }
    }
    
    func testParseUTF32Succeeds() throws {
        let input = [
            "H".unicodeScalars,
            "e".unicodeScalars,
            " ".unicodeScalars,
            "𠁚".unicodeScalars,
            " ".unicodeScalars,
            "l".unicodeScalars,
            "l".unicodeScalars,
            "ö".unicodeScalars,
            " ".unicodeScalars,
            "ࢢ".unicodeScalars,
            " ".unicodeScalars,
            "ω".unicodeScalars,
            "o".unicodeScalars,
            "r".unicodeScalars,
            "l".unicodeScalars,
            "d".unicodeScalars,
            " ".unicodeScalars,
            "𠁄".unicodeScalars,
        ].flatMap { $0.map(\.value) }
        
        let expectedResult = "He 𠁚 llö ࢢ ωorld 𠁄"
        
        let result = try input
            .lazy
            .utf32String
            .tryStore(in: String.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseUTF32Fails() throws {
        let input = [
            "H".unicodeScalars,
            "e".unicodeScalars,
            " ".unicodeScalars,
            "𠁚".unicodeScalars,
            " ".unicodeScalars,
            "l".unicodeScalars,
            "l".unicodeScalars,
            "ö".unicodeScalars,
            " ".unicodeScalars,
            "ࢢ".unicodeScalars,
            " ".unicodeScalars,
            "ω".unicodeScalars,
            "o".unicodeScalars,
            "r".unicodeScalars,
            "l".unicodeScalars,
            "d".unicodeScalars,
            " ".unicodeScalars,
            "𠁄".unicodeScalars,
        ].enumerated().flatMap { (index, scalars) in index == 6 ? [UInt32.max] : scalars.map(\.value) }
                
        let result = input
            .lazy
            .utf32String
        
        try assertThrowsError {
            try result
                .tryStore(in: String.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .parseError)
        }
    }
}
