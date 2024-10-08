import Assertions
import XCTest

@testable import ResultExtensions

final class ResultExtensionsTests: XCTestCase {
    struct TestError: Error {
        let details: String
    }
    
    func testValueSuccess() throws {
        let value = 5
        let result = Result<Int, any Error>.success(value)
        
        try assertEqual(result.value, value)
    }
    
    func testValueFailure() throws {
        let result = Result<Int, any Error>.failure(TestError(details: ""))
        try assertNil(result.value)
    }
    
    func testErrorSuccess() throws {
        let result = Result<Int, any Error>.success(5)
        
        try assertNil(result.error)
    }
    
    func testErrorFailure() throws {
        let result = Result<Int, any Error>.failure(TestError(details: ""))
        try assertNil(result.value)
    }
    
    func testAsyncCatchingSuccess() async throws {
        let errorDetails = "Something"
        let result = Result<Int, any Error>.failure(TestError(details: errorDetails))
        
        try assertEqual((result.error as! TestError?)?.details, errorDetails)
    }
    
    func testAsyncCatchingFail() async throws {
        let errorDetails = "Something"
        
        let result = await Result { () async throws -> Int in
            throw TestError(details: errorDetails)
        }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testEraseErrorTypeSuccess() async throws {
        let result = Result<Int, TestError>.success(5)
            .eraseErrorType()
        
        try assertEqual(try result.get(), 5)
    }
    
    func testEraseErrorTypeFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<Int, TestError>.failure(.init(details: errorDetails))
            .eraseErrorType()
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testCompactSuccessNotNil() async throws {
        let result = Result<Int?, TestError>.success(5)
            .compact()
        
        try assertEqual(try result?.get(), 5)
    }
    
    func testCompactSuccessNil() async throws {
        let result = Result<Int?, TestError>.success(nil)
            .compact()
        
        try assertNil(result)
    }
    
    func testCompactFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<Int?, TestError>.failure(.init(details: errorDetails))
            .compact()
                
        try assertThrowsError { try result?.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testFlattenSuccessSuccess() async throws {
        let result = Result<Result<Int, TestError>, TestError>.success(.success(5))
            .flatten()
        
        try assertEqual(try result.get(), 5)
    }
    
    func testFlattenSuccessFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<Result<Int, TestError>, TestError>.success(.failure(.init(details: errorDetails)))
            .flatten()
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testFlattenFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<Result<Int, TestError>, TestError>.failure(.init(details: errorDetails))
            .flatten()
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testFlattenDifferentErrorsSuccessSuccess() async throws {
        let result = Result<Result<Int, TestError>, Error>.success(.success(5))
            .flatten()
        
        try assertEqual(try result.get(), 5)
    }
    
    func testFlattenDifferentErrorsSuccessFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<Result<Int, TestError>, Error>.success(.failure(.init(details: errorDetails)))
            .flatten()
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testFlattenDifferentErrorsFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<Result<Int, TestError>, Error>.failure(TestError(details: errorDetails))
            .flatten()
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testCompactMapSuccessNotNil() async throws {
        let result = Result<String, TestError>.success("5")
            .compactMap(Int.init)
        
        try assertEqual(try result?.get(), 5)
    }
    
    func testCompactMapSuccessNil() async throws {
        let result = Result<String, TestError>.success("")
            .compactMap(Int.init)
        
        try assertNil(result)
    }
    
    func testCompactMapFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<String, TestError>.failure(.init(details: errorDetails))
            .compactMap(Int.init)
                
        try assertThrowsError { try result?.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryMapSuccessSuccess() async throws {
        let result = Result<String, TestError>.success("5")
            .tryMap { try Int($0) ?? { throw TestError(details: "") }() }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testTryMapSuccessThrows() async throws {
        let errorDetails = "Something"
        
        let result = Result<String, TestError>.success("")
            .tryMap { try Int($0) ?? { throw TestError(details: errorDetails) }() }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryMapFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<String, TestError>.failure(.init(details: errorDetails))
            .tryMap { try Int($0) ?? { throw TestError(details: "") }() }
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryMapErrorSuccessSuccess() async throws {
        let result = Result<Int, TestError>.success(5)
            .tryMapError { _ in TestError(details: "") }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testTryMapErrorFailureSuccess() async throws {
        let errorDetails = "Something"
        let errorDetailsExtra = " Else"
        
        let result = Result<Int, TestError>.failure(.init(details: errorDetails))
            .tryMapError { error in TestError(details: error.details + errorDetailsExtra) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails + errorDetailsExtra)
        }
    }
    
    func testTryMapErrorFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<Int, TestError>.failure(.init(details: ""))
            .tryMapError { error -> TestError in throw TestError(details: errorDetails) }
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryCompactMapSuccessSuccessNotNil() async throws {
        let result = Result<String, TestError>.success("5")
            .tryCompactMap(Int.init)
        
        try assertEqual(try result?.get(), 5)
    }
    
    func testTryCompactMapSuccessSuccessNil() async throws {
        let result = Result<String, TestError>.success("")
            .tryCompactMap(Int.init)
        
        try assertNil(result)
    }
    
    func testTryCompactMapSuccessThrows() async throws {
        let errorDetails = "Something"
        
        let result = Result<String, TestError>.success("")
            .tryCompactMap { _ in throw TestError(details: errorDetails) }
        
        try assertThrowsError { try result?.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }

    func testTryCompactMapFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<String, TestError>.failure(.init(details: errorDetails))
            .tryCompactMap(Int.init)
                
        try assertThrowsError { try result?.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryFlatMapSuccessSuccessSuccess() async throws {
        let result = Result<String, TestError>.success("5")
            .tryFlatMap { string in Result<Int, TestError>.success(Int(string)!) }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testTryFlatMapSuccessFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<String, TestError>.success("5")
            .tryFlatMap { string in Result<Int, TestError>.failure(.init(details: errorDetails)) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryFlatMapSuccessSuccessThrows() async throws {
        let errorDetails = "Something"
        
        let result = Result<String, TestError>.success("")
            .tryFlatMap { _ -> Result<Int, TestError> in throw TestError(details: errorDetails) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }

    func testTryFlatMapFailure() async throws {
        let errorDetails = "Something"
        
        let result = Result<String, TestError>.failure(.init(details: errorDetails))
            .tryFlatMap { string in Result<Int, TestError>.success(Int(string)!) }

        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testCatchSuccess() async throws {
        let result = Result<Int, TestError>.success(5)
            .catch { _ in 6 }
        
        try assertEqual(result, 5)
    }
    
    func testCatchFailure() async throws {
        let errorDetails = "5"
        
        let result = Result<Int, TestError>.failure(.init(details: errorDetails))
            .catch { error in Int(errorDetails) ?? 0 }
        
        try assertEqual(result, 5)
    }
    
    func testTryCatchSuccessSuccess() async throws {
        let result = Result<Int, TestError>.success(5)
            .tryCatch { _ in 6 }
        
        try assertEqual(try result.get(), 5)
    }

    func testTryCatchFailureSuccess() async throws {
        let errorDetails = "5"
        
        let result = Result<Int, TestError>.failure(.init(details: errorDetails))
            .tryCatch { error in Int(errorDetails) ?? 0 }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testTryCatchFailureThrows() async throws {
        let errorDetails = "Something"
        let errorDetailsExtra = " Else"
        
        let result = Result<Int, TestError>.failure(.init(details: errorDetails))
            .tryCatch { error in throw TestError(details: error.details + errorDetailsExtra) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails + errorDetailsExtra)
        }
    }
    
    func testMapAsyncSuccess() async throws {
        let result = await Result<String, TestError>.success("5")
            .mapAsync { Int($0)! }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testMapAsyncFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.failure(.init(details: errorDetails))
            .mapAsync { Int($0)! }
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testMapErrorAsyncSuccess() async throws {
        let result = await Result<Int, TestError>.success(5)
            .mapErrorAsync { _ in TestError(details: "") }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testMapErrorAsyncFailure() async throws {
        let errorDetails = "Something"
        let errorDetailsExtra = " Else"
        
        let result = await Result<String, TestError>.failure(.init(details: errorDetails))
            .mapErrorAsync { error in TestError(details: error.details + errorDetailsExtra) }
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails + errorDetailsExtra)
        }
    }
    
    func testFlatMapAsyncSuccessSuccess() async throws {
        let result = await Result<String, TestError>.success("5")
            .flatMapAsync { string in Result<Int, TestError>.success(Int(string)!) }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testFlatMapAsyncSuccessFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.success("5")
            .flatMapAsync { string in Result<Int, TestError>.failure(.init(details: errorDetails)) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testFlatMapAsyncFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.failure(.init(details: errorDetails))
            .flatMapAsync { string in Result<Int, TestError>.success(Int(string)!) }

        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testFlatMapErrorAsyncSuccessSuccess() async throws {
        let result = await Result<Int, TestError>.success(5)
            .flatMapErrorAsync { _ in .failure(TestError(details: "")) }
        
        try assertEqual(try result.get(), 5)
    }
 
    func testTryFlatErrorMapAsyncFailureSuccess() async throws {
        let errorDetails = "5"
        
        let result = await Result<Int, TestError>.failure(.init(details: errorDetails))
            .flatMapErrorAsync { error in Result<Int, TestError>.success(Int(error.details)!) }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testFlatMapErrorAsyncFailureFailure() async throws {
        let errorDetails = "Something"
        let errorDetailsExtra = " Else"
        
        let result = await Result<String, TestError>.failure(.init(details: errorDetails))
            .flatMapErrorAsync { error in .failure(TestError(details: error.details + errorDetailsExtra)) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails + errorDetailsExtra)
        }
    }
    
    func testCompactMapAsyncSuccessNotNil() async throws {
        let result = await Result<String, TestError>.success("5")
            .compactMapAsync(Int.init)
        
        try assertEqual(try result?.get(), 5)
    }
    
    func testCompactMapAsyncSuccessNil() async throws {
        let result = await Result<String, TestError>.success("")
            .compactMapAsync(Int.init)
        
        try assertNil(result)
    }
    
    func testCompactMapAsyncFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.failure(.init(details: errorDetails))
            .compactMapAsync(Int.init)
                
        try assertThrowsError { try result?.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryMapAsyncSuccessSuccess() async throws {
        let result = await Result<String, TestError>.success("5")
            .tryMapAsync { try Int($0) ?? { throw TestError(details: "") }() }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testTryMapAsyncSuccessThrows() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.success("")
            .tryMapAsync { try Int($0) ?? { throw TestError(details: errorDetails) }() }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryMapAsyncFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.failure(.init(details: errorDetails))
            .tryMapAsync { try Int($0) ?? { throw TestError(details: "") }() }
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryMapErrorAsyncSuccessSuccess() async throws {
        let result = await Result<Int, TestError>.success(5)
            .tryMapErrorAsync { _ in TestError(details: "") }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testTryMapErrorAsyncFailureSuccess() async throws {
        let errorDetails = "Something"
        let errorDetailsExtra = " Else"
        
        let result = await Result<Int, TestError>.failure(.init(details: errorDetails))
            .tryMapErrorAsync { error in TestError(details: error.details + errorDetailsExtra) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails + errorDetailsExtra)
        }
    }
    
    func testTryMapErrorAsyncFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<Int, TestError>.failure(.init(details: ""))
            .tryMapErrorAsync { error -> TestError in throw TestError(details: errorDetails) }
                
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryCompactMapAsyncSuccessSuccessNotNil() async throws {
        let result = await Result<String, TestError>.success("5")
            .tryCompactMapAsync(Int.init)
        
        try assertEqual(try result?.get(), 5)
    }
    
    func testTryCompactMapAsyncSuccessSuccessNil() async throws {
        let result = await Result<String, TestError>.success("")
            .tryCompactMapAsync(Int.init)
        
        try assertNil(result)
    }
    
    func testTryCompactMapAsyncSuccessThrows() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.success("")
            .tryCompactMapAsync { _ in throw TestError(details: errorDetails) }
        
        try assertThrowsError { try result?.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }

    func testTryCompactMapAsyncFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.failure(.init(details: errorDetails))
            .tryCompactMapAsync(Int.init)
                
        try assertThrowsError { try result?.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryFlatMapAsyncSuccessSuccessSuccess() async throws {
        let result = await Result<String, TestError>.success("5")
            .tryFlatMapAsync { string in Result<Int, TestError>.success(Int(string)!) }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testTryFlatMapAsyncSuccessFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.success("5")
            .tryFlatMapAsync { string in Result<Int, TestError>.failure(.init(details: errorDetails)) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testTryFlatMapAsyncSuccessSuccessThrows() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.success("")
            .tryFlatMapAsync { _ -> Result<Int, TestError> in throw TestError(details: errorDetails) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }

    func testTryFlatMapAsyncFailure() async throws {
        let errorDetails = "Something"
        
        let result = await Result<String, TestError>.failure(.init(details: errorDetails))
            .tryFlatMapAsync { string in Result<Int, TestError>.success(Int(string)!) }

        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails)
        }
    }
    
    func testCatchAsyncSuccess() async throws {
        let result = await Result<Int, TestError>.success(5)
            .catchAsync { _ in 6 }
        
        try assertEqual(result, 5)
    }
    
    func testCatchAsyncFailure() async throws {
        let errorDetails = "5"
        
        let result = await Result<Int, TestError>.failure(.init(details: errorDetails))
            .catchAsync { error in Int(errorDetails) ?? 0 }
        
        try assertEqual(result, 5)
    }
    
    func testTryCatchAsyncSuccessSuccess() async throws {
        let result = await Result<Int, TestError>.success(5)
            .tryCatchAsync { _ in 6 }
        
        try assertEqual(try result.get(), 5)
    }

    func testTryCatchAsyncFailureSuccess() async throws {
        let errorDetails = "5"
        
        let result = await Result<Int, TestError>.failure(.init(details: errorDetails))
            .tryCatchAsync { error in Int(errorDetails) ?? 0 }
        
        try assertEqual(try result.get(), 5)
    }
    
    func testTryCatchAsyncFailureThrows() async throws {
        let errorDetails = "Something"
        let errorDetailsExtra = " Else"
        
        let result = await Result<Int, TestError>.failure(.init(details: errorDetails))
            .tryCatchAsync { error in throw TestError(details: error.details + errorDetailsExtra) }
        
        try assertThrowsError { try result.get() } errorHandler: { error in
            guard let error = error as? TestError else {
                throw Fail("Error should be TestError")
            }
            
            try assertEqual(error.details, errorDetails + errorDetailsExtra)
        }
    }
}
