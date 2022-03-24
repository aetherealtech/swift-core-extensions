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

    public mutating func getAndSet(_ setter: (inout T) -> Void) -> T {

        lock.exclusiveLock {

            let value = _value
            setter(&_value)
            return value
        }
    }

    private var _value: T
    private let lock = ReadWriteLock()
}