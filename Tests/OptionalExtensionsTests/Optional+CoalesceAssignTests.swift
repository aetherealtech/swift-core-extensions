import Assertions
import XCTest

@testable import OptionalExtensions

final class OptionalCoalesceAssignTests: XCTestCase {
    func testAssignIfNilNil() throws {
        var nilOptional: Int? = nil
        
        let result = nilOptional.assignIfNil(5)
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }
    
    func testAssignIfNilNotNil() throws {
        var nilOptional: Int? = 3
        
        let result = nilOptional.assignIfNil(5)
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }
    
    func testAssignIfNilComputeNil() throws {
        var nilOptional: Int? = nil
        
        let result: Int = nilOptional.assignIfNil({
            return 5
        }())
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }
    
    func testAssignIfNilComputeNotNil() throws {
        var nilOptional: Int? = 3
        
        let result: Int = try nilOptional.assignIfNil({
            throw Fail("Should not have run")
        }())
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }
    
    func testAssignIfNilOptionalNil() throws {
        var nilOptional: Int? = nil
        
        let result: Int? = nilOptional.assignIfNil(5 as Int?)
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }
    
    func testAssignIfNilOptionalNotNil() throws {
        var nilOptional: Int? = 3
        
        let result: Int? = nilOptional.assignIfNil(5 as Int?)
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }
    
    func testAssignIfNilOptionalComputeNil() throws {
        var nilOptional: Int? = nil
        
        let result: Int? = nilOptional.assignIfNil({
            5 as Int?
        }())
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }
    
    func testAssignIfNilOptionalComputeNotNil() throws {
        var nilOptional: Int? = 3
        
        let result: Int? = try nilOptional.assignIfNil({
            throw Fail("Should not have run")
        }())
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testAssignIfNilAsyncComputeNil() async throws {
        var nilOptional: Int? = nil
        
        let result: Int = await nilOptional.assignIfNil {
            5
        }
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testAssignIfNilAsyncComputeNotNil() async throws {
        var nilOptional: Int? = 3
        
        let result: Int = try await nilOptional.assignIfNil {
            throw Fail("Should not have run")
        }
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testAssignIfNilAsyncOptionalNil() async throws {
        var nilOptional: Int? = nil
        
        let result: Int? = await nilOptional.assignIfNil {
            5 as Int?
        }
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testAssignIfNilAsyncOptionalNotNil() async throws {
        var nilOptional: Int? = 3
        
        let result: Int? = try await nilOptional.assignIfNil {
            throw Fail("Should not have run")
        }
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testAssignIfNilAsyncOptionalComputeNil() async throws {
        var nilOptional: Int? = nil
        
        let result: Int? = await nilOptional.assignIfNil {
            return 5 as Int?
        }
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testAssignIfNilAsyncOptionalComputeNotNil() async throws {
        var nilOptional: Int? = 3
        
        let result: Int? = try await nilOptional.assignIfNil {
            throw Fail("Should not have run")
        }
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }
    
    func testCoalesceAssignNil() throws {
        var nilOptional: Int? = nil
        
        let result = nilOptional ??= 5
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }

    func testCoalesceAssignNotNil() throws {
        var nilOptional: Int? = 3
        
        let result = nilOptional ??= 5
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }

    func testCoalesceAssignComputeNil() throws {
        var nilOptional: Int? = nil
        
        let result: Int = nilOptional ??= {
            return 5
        }()
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }

    func testCoalesceAssignComputeNotNil() throws {
        var nilOptional: Int? = 3
        
        let result: Int = try nilOptional ??= {
            throw Fail("Should not have run")
        }()
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }

    func testCoalesceAssignOptionalNil() throws {
        var nilOptional: Int? = nil
        
        let result: Int? = nilOptional ??= 5 as Int?
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }

    func testCoalesceAssignOptionalNotNil() throws {
        var nilOptional: Int? = 3
        
        let result: Int? = nilOptional ??= 5 as Int?
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }

    func testCoalesceAssignOptionalComputeNil() throws {
        var nilOptional: Int? = nil
        
        let result: Int? = nilOptional ??= {
            5 as Int?
        }()
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }

    func testCoalesceAssignOptionalComputeNotNil() throws {
        var nilOptional: Int? = 3
        
        let result: Int? = try nilOptional ??= {
            throw Fail("Should not have run")
        }()
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testCoalesceAssignAsyncComputeNil() async throws {
        var nilOptional: Int? = nil
        
        let result: Int = await nilOptional ??= {
            5
        }
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testCoalesceAssignAsyncComputeNotNil() async throws {
        var nilOptional: Int? = 3
        
        let result: Int = try await nilOptional ??= {
            throw Fail("Should not have run")
        }
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testCoalesceAssignAsyncOptionalNil() async throws {
        var nilOptional: Int? = nil
        
        let result: Int? = await nilOptional ??= {
            5 as Int?
        }
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testCoalesceAssignAsyncOptionalNotNil() async throws {
        var nilOptional: Int? = 3
        
        let result: Int? = try await nilOptional ??= {
            throw Fail("Should not have run")
        }
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testCoalesceAssignAsyncOptionalComputeNil() async throws {
        var nilOptional: Int? = nil
        
        let result: Int? = await nilOptional ??= {
            return 5 as Int?
        }
        
        try assertEqual(nilOptional, 5)
        try assertEqual(result, 5)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func testCoalesceAssignAsyncOptionalComputeNotNil() async throws {
        var nilOptional: Int? = 3
        
        let result: Int? = try await nilOptional ??= {
            throw Fail("Should not have run")
        }
        
        try assertEqual(nilOptional, 3)
        try assertEqual(result, 3)
    }

}
