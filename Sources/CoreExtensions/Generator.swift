//
//  Created by Daniel Coleman on 1/12/22.
//

import Foundation

public struct Generator<Element> : Sequence {

    public struct GeneratorIterator : IteratorProtocol {

        init(generator: @escaping () -> Element?) {

            self.generator = generator
        }

        public mutating func next() -> Element? {

            let current = generator()
            self.current = current
            return current
        }

        let generator: () -> Element?
        var current: Element? = nil
    }

    public typealias Iterator = GeneratorIterator

    public func makeIterator() -> Iterator {

        GeneratorIterator(generator: generator)
    }

    public init(_ generator: @escaping () -> Element?) {

        self.generator = generator
    }

    private let generator: () -> Element?
}

public struct Generators {

    @available(*, unavailable) private init() {}
}

extension Generators {

    public static func sequence<T>(_ sequence: @escaping (Int) -> T) -> Generator<T> {

        var index = 0

        return Generator { () -> T? in

            let next = sequence(index)
            index += 1

            return next
        }
    }

    public static func fibonacciSequence() -> Generator<Int> {

        var values = (0, 1)

        return Generator { () -> Int? in

            let next = values.0 + values.1
            values.0 = values.1
            values.1 = next

            return next
        }
    }
}