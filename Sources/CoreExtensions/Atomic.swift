//
// Created by Daniel Coleman on 2/19/22.
//

import Foundation

public struct Atomic<T> {

    public init(_ value: T) {

        self._value = value
    }

    public var value: T {
        get {
            queue.sync { _value }
        }
        set {
            queue.sync(flags: [.barrier]) { _value = newValue }
        }
    }

    public mutating func getAndSet(_ setter: (inout T) -> Void) -> T {

        queue.sync(flags: [.barrier]) {

            let value = self._value
            setter(&self._value)
            return value
        }
    }

    private var _value: T
    private let queue = DispatchQueue(label: "com.aetherealtech.eventstreams.atomic", attributes: [.concurrent])
}