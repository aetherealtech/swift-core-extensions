import Assertions
import XCTest

@testable import AsyncCollectionExtensions

final class LazySequenceStringTests: XCTestCase {
    func testASCIISucceeds() async throws {
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
        
        let result = try await input
            .async
            .ascii
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testASCIIFails() async throws {
        let input = "Hellö World"

        let result = input
            .async
            .ascii
        
        try await assertThrowsError {
            try await result
                .store(in: Array.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .invalidASCIICharacter)
        }
    }
    
    func testUTF8() async throws {
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
        
        let result = await input
            .async
            .utf8
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testUTF16() async throws {
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
        
        let result = await input
            .async
            .utf16
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testUTF32() async throws {
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
        
        let result = await input
            .async
            .utf32
            .store(in: Array.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseASCIISucceeds() async throws {
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

        let result = try await input
            .async
            .asciiString
            .store(in: String.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseASCIIFails() async throws {
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
            .async
            .asciiString
        
        try await assertThrowsError {
            try await result
                .store(in: String.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .invalidASCIICharacter)
        }
    }
    
    func testParseUTF8Succeeds() async throws {
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
        
        let result = try await input
            .async
            .utf8String
            .store(in: String.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseUTF8Fails() async throws {
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
            .async
            .utf8String
        
        try await assertThrowsError {
            try await result
                .store(in: String.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .parseError)
        }
    }
    
    func testParseUTF16Succeeds() async throws {
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
        
        let result = try await input
            .async
            .utf16String
            .store(in: String.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseUTF16Fails() async throws {
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
            .async
            .utf16String
        
        try await assertThrowsError {
            try await result
                .store(in: String.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .parseError)
        }
    }
    
    func testParseUTF32Succeeds() async throws {
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
        
        let result = try await input
            .async
            .utf32String
            .store(in: String.self)
        
        try assertEqual(expectedResult, result)
    }
    
    func testParseUTF32Fails() async throws {
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
            .async
            .utf32String
        
        try await assertThrowsError {
            try await result
                .store(in: String.self)
        } errorHandler: { error in
            try assertTrue(error as? StringParseError == .parseError)
        }
    }
}
