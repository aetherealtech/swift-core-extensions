import Foundation

public struct BetterDecodingError: LocalizedError {
    public let underlyingError: DecodingError

    public var errorDescription: String? {
        switch underlyingError {
            case let .dataCorrupted(context):
                return "DATA CORRUPTED - Path:\(context.codingPath.map(\.stringValue)), \(context.debugDescription), \(context.underlyingError?.localizedDescription ?? "")"
            case let .typeMismatch(type, context):
                return "TYPE MISMATCH: \(type) - Path:\(context.codingPath.map(\.stringValue)), \(context.debugDescription), \(context.underlyingError?.localizedDescription ?? "")"
            case let .keyNotFound(key, context):
                return "TYPE MISMATCH: \(key) - Path:\(context.codingPath.map(\.stringValue)), \(context.debugDescription), \(context.underlyingError?.localizedDescription ?? "")"
            case let .valueNotFound(value, context):
                return "TYPE MISMATCH: \(value) - Path:\(context.codingPath.map(\.stringValue)), \(context.debugDescription), \(context.underlyingError?.localizedDescription ?? "")"
            default:
                return "UNKNOWN DECODING ERROR"
        }
    }
}

public extension Error {
    var betterDecodingError: Error {
        if let decodingError = self as? DecodingError {
            return BetterDecodingError(underlyingError: decodingError)
        }

        return self
    }
}
