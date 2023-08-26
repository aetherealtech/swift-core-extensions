public extension Numeric {
    func isApproximately(_ other: Self, tolerance: Self.Magnitude) -> Bool {
        (self - other).magnitude <= tolerance
    }
}

public extension Optional where Wrapped: Numeric {
    func isApproximately(_ other: Self, tolerance: Wrapped.Magnitude) -> Bool {
        if let self, let other {
            return self.isApproximately(other, tolerance: tolerance)
        }

        return false
    }
}
