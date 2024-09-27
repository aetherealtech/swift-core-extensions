import Assertions
import XCTest

@testable import CollectionExtensions

final class DataTests: XCTestCase {
    func testStringWithEncoding() throws {
        try testStringWithEncoding(type: Data.self)
        try testStringWithEncoding(type: [UInt8].self)
    }
    
    private func testStringWithEncoding<S: RangeReplaceableCollection<UInt8>>(type: S.Type) throws {
        let encodings = [
            String.Encoding.utf8,
            String.Encoding.utf16,
            String.Encoding.utf32,
        ]
        
        let expectedResult = "BláhBláh"
        
        for encoding in encodings {
            let data = S(expectedResult.data(using: encoding)!)
            
            let result = data.string(encoding: encoding)
            
            try assertEqual(expectedResult, result)
        }
    }
}
