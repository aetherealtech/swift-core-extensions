//
// Created by Daniel Coleman on 2/19/22.
//

import Foundation

public struct Atomic<T> {

    public init(_ value: T) {

        _value = value
    }

    public var value: T {
        get {
            lock.lock { _value }
        }
        set {
            lock.exclusiveLock { _value = newValue }
        }
    }

    public func lock<Result>(_ getter: (T) -> Result) -> Result {

        lock.lock({ getter(_value) })
    }

    public mutating func exclusiveLock<Result>(_ getter: (inout T) -> Result) -> Result {

        lock.exclusiveLock({ getter(&_value) })
    }

    public mutating func getAndSet(_ setter: (inout T) -> Void) -> T {

        exclusiveLock { value in

            let originalValue = value
            setter(&value)
            return originalValue
        }
    }

    private var _value: T
    private let lock = ReadWriteLock()
}