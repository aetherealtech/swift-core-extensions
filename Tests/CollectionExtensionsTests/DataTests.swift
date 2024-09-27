import Assertions
import XCTest

@testable import CollectionExtensions

final class DataTests: XCTestCase {
    func testStringWithEncoding() throws {
        let types: [any RangeReplaceableCollection<UInt8>.Type] = [
            [UInt8].self,
            Data.self
        ]
        
        let encodings = [
            String.Encoding.utf8,
            String.Encoding.utf16,
            String.Encoding.utf32,
        ]
        
        let expectedResult = "BláhBláh"
        
        for encoding in encodings {
            let data = expectedResult.data(using: encoding)!
            
            for type in types {
                let data = type.init(data)
                
                let result = data.string(encoding: encoding)
                
                try assertEqual(expectedResult, result)
            }
        }
    }
}
