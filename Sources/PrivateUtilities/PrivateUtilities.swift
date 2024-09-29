// These are extracted out of other modules because they can't be covered by unit tests, and this way test coverage can be 100% in the public modules.

public extension Dictionary {
    mutating func insertOrFailOnDuplicate(key: Key, value: Value) {
        guard self[key] == nil else {
            fatalError("Duplicate values for key: '\(key)'")
        }
        self[key] = value
    }
}
