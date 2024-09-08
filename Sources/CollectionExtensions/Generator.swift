import Foundation

public struct Generator<Element> : Sequence {
    public struct Iterator : IteratorProtocol {
        init(generator: @escaping () -> Element?) {
            self.generator = generator
        }

        public mutating func next() -> Element? {
            generator()
        }

        let generator: () -> Element?
    }

    public func makeIterator() -> Iterator {
        .init(generator: generator)
    }

    public init(_ generator: @escaping () -> Element?) {
        self.generator = generator
    }

    private let generator: () -> Element?
}

public enum Generators {

}

extension Generators {
    public static func sequence<T>(
        _ sequence: @escaping (Int) -> T?
    ) -> Generator<T> {
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
