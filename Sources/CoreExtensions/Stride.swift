//
//  Created by Daniel Coleman on 1/12/22.
//

import Foundation

@inlinable public func stride<T>(from start: T, by stride: T.Stride, count: Int) -> StrideCount<T> where T : Strideable {

    StrideCount(
        start: start,
        stride: stride,
        count: count
    )
}

@frozen public struct StrideCount<Element> : Sequence where Element : Strideable {

    public struct StrideCountIterator : IteratorProtocol {

        public init(
            start: Element,
            stride: Element.Stride,
            count: Int
        ) {

            self.current = start
            self.stride = stride
            self.count = count
        }

        public mutating func next() -> Element? {

            guard let current = self.current else {
                return nil
            }

            if index < count - 1 {

                self.current = current.advanced(by: stride)
                index += 1

            } else {

                self.current = nil
            }

            return current
        }

        var current: Element?
        var index = 0

        let stride: Element.Stride
        let count: Int
    }

    public init(
        start: Element,
        stride: Element.Stride,
        count: Int
    ) {

        self.start = start
        self.stride = stride
        self.count = count
    }

    @inlinable public func makeIterator() -> StrideCountIterator {

        StrideCountIterator(
            start: start,
            stride: stride,
            count: count
        )
    }

    public let start: Element
    public let stride: Element.Stride
    public let count: Int
}
