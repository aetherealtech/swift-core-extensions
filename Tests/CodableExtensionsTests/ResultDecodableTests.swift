import Assertions
import XCTest

@testable import CodableExtensions

final class ResultDecodableTests: XCTestCase {
    func testDecodeSuccess() throws {
        let decoded = try JSONDecoder().decode(Result<Int, any Error>.self, from: "12345".data(using: .utf8)!)
        
        try assertEqual(12345, try decoded.get())
    }
    
    func testDecodeFailure() throws {
        let decoded = try JSONDecoder().decode(Result<Int, any Error>.self, from: "\"Hello\"".data(using: .utf8)!)
        
        try assertThrowsError {
            try decoded.get()
        } errorHandler: { error in
            try assertEqual("TYPE MISMATCH: Int - Path:[], Expected to decode Int but found a string instead., No underlying error", error.betterDecodingError.localizedDescription)
        }
    }
}
