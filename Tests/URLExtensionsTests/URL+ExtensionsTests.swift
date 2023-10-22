import Assertions
import CollectionExtensions
import PDFKit
import XCTest

@testable import URLExtensions

final class URLExtensionsTests: XCTestCase {
    func testDataPlain() throws {
        let data = "DewdWhazzup"
        
        let url = URL.data(
            data,
            type: "plain",
            base64Encoded: false
        )
        
        let result = try Data(contentsOf: url)
        
        try assertEqual(String(data: result, encoding: .utf8) ?? "", data)
    }
    
    func testDataBase64() throws {
        let document = PDFDocument(url: Bundle.module.url(forResource: "dummy", withExtension: "pdf")!)!
        let data = document.dataRepresentation()!
        
        let url = URL.data(
            data,
            type: "pdf"
        )
        
        let result = try Data(contentsOf: url)
        
        try assertEqual(result, data)
    }
}
