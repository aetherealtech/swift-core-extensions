//
//  Created by Daniel Coleman on 1/12/22.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct AsyncGenerator<Element> : AsyncSequence {

    public struct GeneratorIterator : AsyncIteratorProtocol {

        init(generator: @escaping () async throws -> Element?) {

            self.generator = generator
        }

        public mutating func next() async throws -> Element? {

            let current = try await generator()
            self.current = current
            return current
        }

        let generator: () async throws -> Element?
        var current: Element? = nil
    }

    public typealias AsyncIterator = GeneratorIterator

    public func makeAsyncIterator() -> AsyncIterator {

        GeneratorIterator(generator: generator)
    }

    public init(_ generator: @escaping () async throws -> Element?) {

        self.generator = generator
    }

    private let generator: () async throws -> Element?
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public struct AsyncGenerators {

    @available(*, unavailable) private init() {}
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension AsyncGenerators {

    public static func sequence<T>(_ sequence: @escaping (Int) async throws -> T?) -> AsyncGenerator<T> {

        var index = 0

        return AsyncGenerator { () async throws -> T? in

            let next = try await sequence(index)
            index += 1

            return next
        }
    }
}