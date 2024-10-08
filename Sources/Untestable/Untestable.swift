// These are extracted out of other modules because they can't be covered by unit tests, and this way test coverage can be 100% in the public modules.

public extension Dictionary {
    mutating func insertOrFailOnDuplicate(key: Key, value: Value) {
        guard self[key] == nil else {
            fatalError("Duplicate values for key: '\(key)'")
        }
        self[key] = value
    }
}

public func notSupportedOnThisPlatform<each Ts, E: Error, R>() -> (_: repeat each Ts) throws(E) -> R {
    { (_: repeat each Ts) throws(E) -> R in fatalError("Not supported on this platform") }
}

// There's no way to hit the `@unknown default` from tests, that's why this is here.
public extension DecodingError {
    @_alwaysEmitIntoClient @inlinable @inline(__always)
    func visit<R>(
        typeMismatch visitTypeMismatch: (any Any.Type, DecodingError.Context) -> R,
        valueNotFound visitValueNotFound: (any Any.Type, DecodingError.Context) -> R,
        keyNotFound visitKeyNotFound: (any CodingKey, DecodingError.Context) -> R,
        dataCorrupted visitDataCorrupted: (DecodingError.Context) -> R,
        default: R
    ) -> R {
        switch self {
            case let .typeMismatch(type, context): visitTypeMismatch(type, context)
            case let .valueNotFound(type, context): visitValueNotFound(type, context)
            case let .keyNotFound(key, context): visitKeyNotFound(key, context)
            case let .dataCorrupted(context): visitDataCorrupted(context)
            @unknown default: `default`
        }
    }
}
