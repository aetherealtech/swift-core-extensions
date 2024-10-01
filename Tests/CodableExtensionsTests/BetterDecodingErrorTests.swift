import Assertions
import XCTest

@testable import CodableExtensions

struct UnderlyingError: LocalizedError {
    var errorDescription: String? { "The underlying error" }
}

protocol UnderlyingErrorSelector {
    static var underlyingError: UnderlyingError? { get }
}

struct UnderlyingErrorPresent: UnderlyingErrorSelector {
    static var underlyingError: UnderlyingError? { .init() }
}

struct UnderlyingErrorAbsent: UnderlyingErrorSelector {
    static var underlyingError: UnderlyingError? { nil }
}

struct DataCorrupted<UnderlyingError: UnderlyingErrorSelector>: Decodable {
    init(from decoder: any Decoder) throws {
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Test Data Corrupted Message", underlyingError: UnderlyingError.underlyingError))
    }
}

struct TypeMismatch<UnderlyingError: UnderlyingErrorSelector>: Decodable {
    init(from decoder: any Decoder) throws {
        throw DecodingError.typeMismatch(Int.self, .init(codingPath: decoder.codingPath, debugDescription: "Test Type Mismatch Message", underlyingError: UnderlyingError.underlyingError))
    }
}

struct KeyNotFound<UnderlyingError: UnderlyingErrorSelector>: Decodable {
    enum CodingKeys: String, CodingKey {
        case example
    }
    
    init(from decoder: any Decoder) throws {
        throw DecodingError.keyNotFound(CodingKeys.example, .init(codingPath: decoder.codingPath, debugDescription: "Test Missing Key Message", underlyingError: UnderlyingError.underlyingError))
    }
}

struct ValueNotFound<UnderlyingError: UnderlyingErrorSelector>: Decodable {
    init(from decoder: any Decoder) throws {
        throw DecodingError.valueNotFound(Int.self, .init(codingPath: decoder.codingPath, debugDescription: "Test Value Not Found Message", underlyingError: UnderlyingError.underlyingError))
    }
}

struct OtherError: LocalizedError {
    var errorDescription: String? { "The usual description" }
}

struct TestContainer<T: Decodable>: Decodable {
    struct LevelOne: Decodable {
        struct LevelTwo: Decodable {
            struct LevelThree: Decodable {
                let value: T
            }
            
            let levelThree: LevelThree
        }
        
        let levelTwo: LevelTwo
    }
    
    let levelOne: LevelOne
}

final class BetterDecodingErrorTests: XCTestCase {
    let data = """
    {
      "levelOne": {
        "levelTwo": {
          "levelThree": {
            "value": "BlahBlah"
          }
        }
      }
    }
    """.data(using: .utf8)!
    
    func testDescriptionDataCorrupted() throws {
        try assertThrowsError {
            try JSONDecoder().decode(TestContainer<DataCorrupted<UnderlyingErrorPresent>>.self, from: data)
        } errorHandler: { error in
            let description = error.betterDecodingError.localizedDescription
            
            try assertEqual("DATA CORRUPTED - Path:[\"levelOne\", \"levelTwo\", \"levelThree\", \"value\"], Test Data Corrupted Message, The underlying error", description)
        }
        
        try assertThrowsError {
            try JSONDecoder().decode(TestContainer<DataCorrupted<UnderlyingErrorAbsent>>.self, from: data)
        } errorHandler: { error in
            let description = error.betterDecodingError.localizedDescription
            
            try assertEqual("DATA CORRUPTED - Path:[\"levelOne\", \"levelTwo\", \"levelThree\", \"value\"], Test Data Corrupted Message, No underlying error", description)
        }
    }
    
    func testDescriptionTypeMismatch() throws {
        try assertThrowsError {
            try JSONDecoder().decode(TestContainer<TypeMismatch<UnderlyingErrorPresent>>.self, from: data)
        } errorHandler: { error in
            let description = error.betterDecodingError.localizedDescription
            
            try assertEqual("TYPE MISMATCH: Int - Path:[\"levelOne\", \"levelTwo\", \"levelThree\", \"value\"], Test Type Mismatch Message, The underlying error", description)
        }
        
        try assertThrowsError {
            try JSONDecoder().decode(TestContainer<TypeMismatch<UnderlyingErrorAbsent>>.self, from: data)
        } errorHandler: { error in
            let description = error.betterDecodingError.localizedDescription
            
            try assertEqual("TYPE MISMATCH: Int - Path:[\"levelOne\", \"levelTwo\", \"levelThree\", \"value\"], Test Type Mismatch Message, No underlying error", description)
        }
    }
    
    func testDescriptionKeyNotFound() throws {
        try assertThrowsError {
            try JSONDecoder().decode(TestContainer<KeyNotFound<UnderlyingErrorPresent>>.self, from: data)
        } errorHandler: { error in
            let description = error.betterDecodingError.localizedDescription
            
            try assertEqual("KEY NOT FOUND: CodingKeys(stringValue: \"example\", intValue: nil) - Path:[\"levelOne\", \"levelTwo\", \"levelThree\", \"value\"], Test Missing Key Message, The underlying error", description)
        }
        
        try assertThrowsError {
            try JSONDecoder().decode(TestContainer<KeyNotFound<UnderlyingErrorAbsent>>.self, from: data)
        } errorHandler: { error in
            let description = error.betterDecodingError.localizedDescription
            
            try assertEqual("KEY NOT FOUND: CodingKeys(stringValue: \"example\", intValue: nil) - Path:[\"levelOne\", \"levelTwo\", \"levelThree\", \"value\"], Test Missing Key Message, No underlying error", description)
        }
    }
    
    func testDescriptionValueNotFound() throws {
        try assertThrowsError {
            try JSONDecoder().decode(TestContainer<ValueNotFound<UnderlyingErrorPresent>>.self, from: data)
        } errorHandler: { error in
            let description = error.betterDecodingError.localizedDescription
            
            try assertEqual("VALUE NOT FOUND: Int - Path:[\"levelOne\", \"levelTwo\", \"levelThree\", \"value\"], Test Value Not Found Message, The underlying error", description)
        }
        
        try assertThrowsError {
            try JSONDecoder().decode(TestContainer<ValueNotFound<UnderlyingErrorAbsent>>.self, from: data)
        } errorHandler: { error in
            let description = error.betterDecodingError.localizedDescription
            
            try assertEqual("VALUE NOT FOUND: Int - Path:[\"levelOne\", \"levelTwo\", \"levelThree\", \"value\"], Test Value Not Found Message, No underlying error", description)
        }
    }
    
    func testNonDecodingError() throws {
        let error = OtherError().betterDecodingError
        
        try assertEqual("The usual description", error.localizedDescription)
    }
}
