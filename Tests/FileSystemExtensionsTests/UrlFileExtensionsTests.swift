import Assertions
import XCTest

@testable import FileSystemExtensions

final class UrlFileExtensionsTests: XCTestCase {
    func testRelativePathAdded() throws {
        let first = URL(fileURLWithPath: "/somewhere/something/else/and/also/this")
        let second = URL(fileURLWithPath: "/somewhere/something")
        
        let expectedResult = "else/and/also/this"
        
        let result = try first.relativePath(from: second)
        
        try assertEqual(expectedResult, result)
    }
    
    func testRelativePathRemoved() throws {
        let first = URL(fileURLWithPath: "/somewhere/something")
        let second = URL(fileURLWithPath: "/somewhere/something/else/and/also/this")
        
        let expectedResult = "../../../.."
        
        let result = try first.relativePath(from: second)
        
        try assertEqual(expectedResult, result)
    }
    
    func testRelativePathRemovedAndAdded() throws {
        let first = URL(fileURLWithPath: "/somewhere/something/other/than/that")
        let second = URL(fileURLWithPath: "/somewhere/something/else/and/also/this")
        
        let expectedResult = "../../../../other/than/that"
        
        let result = try first.relativePath(from: second)
        
        try assertEqual(expectedResult, result)
    }
    
    func testRelativePathInvalidUrl() throws {
        let first = URL(string: "http://somewhere.com/something/else")!
        let second = URL(string: "http://somewhere.com/something")!
        
        try assertThrowsError {
            try first.relativePath(from: second)
        } errorHandler: { error in
            guard let error = error as? RelativePathError, case let .nonFileURL(url) = error else {
                throw Fail("Expected a non file URL error")
            }
            
            try assertEqual(url, first)
            try assertEqual("\(url) is not a file URL", error.localizedDescription)
        }
    }
}
