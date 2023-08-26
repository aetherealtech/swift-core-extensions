import Foundation

public extension Decimal {
    var intValue: Int {
        (self as NSDecimalNumber).intValue
    }

    var floatValue: Float {
        (self as NSDecimalNumber).floatValue
    }

    var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
    }

    var stringValue: String {
        (self as NSDecimalNumber).stringValue
    }
}

public extension Decimal {
    static func random(in range: Range<Decimal>) -> Decimal {
        Decimal(Double.random(in: range.lowerBound.doubleValue ..< range.upperBound.doubleValue))
    }
}
