import Foundation
import Untestable

public struct BetterDecodingError: LocalizedError {
    public let underlyingError: DecodingError

    public var errorDescription: String? {
        underlyingError.visit(
            typeMismatch: { type, context in "TYPE MISMATCH: \(type) - Path:\(context.codingPath.map(\.stringValue)), \(context.debugDescription), \(context.underlyingError?.localizedDescription ?? "No underlying error")" },
            valueNotFound: { type, context in "VALUE NOT FOUND: \(type) - Path:\(context.codingPath.map(\.stringValue)), \(context.debugDescription), \(context.underlyingError?.localizedDescription ?? "No underlying error")" },
            keyNotFound: { key, context in "KEY NOT FOUND: \(key) - Path:\(context.codingPath.map(\.stringValue)), \(context.debugDescription), \(context.underlyingError?.localizedDescription ?? "No underlying error")" },
            dataCorrupted: { context in "DATA CORRUPTED - Path:\(context.codingPath.map(\.stringValue)), \(context.debugDescription), \(context.underlyingError?.localizedDescription ?? "No underlying error")" },
            default: "UNKNOWN DECODING ERROR"
        )
    }
}

public extension Error {
    var betterDecodingError: any Error {
        if let decodingError = self as? DecodingError {
            return BetterDecodingError(underlyingError: decodingError)
        }

        return self
    }
}
