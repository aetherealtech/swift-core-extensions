//
// Created by Daniel Coleman on 2/20/22.
//

import Foundation
import CoreGraphics

public protocol Randomizable {

    static func random() -> Self
}

public protocol RangeRandomizable : Randomizable where Self: Comparable {

    static func random(in range: ClosedRange<Self>) -> Self
}

extension RangeRandomizable where Self: FixedWidthInteger {

    public static func random() -> Self {

        random(in: Self.min...Self.max)
    }
}

extension RangeRandomizable where Self: BinaryFloatingPoint {

    public static func random() -> Self {

        random(in: -Self.greatestFiniteMagnitude...Self.greatestFiniteMagnitude)
    }
}

extension Int: RangeRandomizable {}
extension Int8: RangeRandomizable {}
extension Int16: RangeRandomizable {}
extension Int32: RangeRandomizable {}
extension Int64: RangeRandomizable {}

extension UInt: RangeRandomizable {}
extension UInt8: RangeRandomizable {}
extension UInt16: RangeRandomizable {}
extension UInt32: RangeRandomizable {}
extension UInt64: RangeRandomizable {}

#if !os(macOS)
extension Float16: RangeRandomizable {}
#endif

extension Float: RangeRandomizable {}
extension Double: RangeRandomizable {}
extension Float80: RangeRandomizable {}
extension CGFloat: RangeRandomizable {}

extension SetAlgebra {

    public init<Source>(_ source: Source) where Element == Source.Element, Source : Sequence {

        self.init()

        for element in source {
            insert(element)
        }
    }
}

extension Collection {

    static func random(factory: (CoreExtensions.Generator<Element>) -> Self, elementGenerator: @escaping () -> Element) -> Self {

        let count = Int.random(in: 0...Int.max)

        let generator = Generators.sequence { index -> Element? in

            guard index < count else {
                return nil
            }

            return elementGenerator()
        }

        return factory(generator)
    }
}

extension RangeReplaceableCollection {

    public static func random(elementGenerator: @escaping () -> Element) -> Self {

        random(factory: Self.init, elementGenerator: elementGenerator)
    }
}

extension RangeReplaceableCollection where Element: Randomizable {

    public static func random() -> Self {

        random(elementGenerator: Element.random)
    }
}

extension RangeReplaceableCollection where Element: RangeRandomizable {

    public static func random(elementRange: ClosedRange<Element>) -> Self {

        random(elementGenerator: { Element.random(in: elementRange) })
    }
}

extension SetAlgebra where Self: Collection {

    public static func random(elementGenerator: @escaping () -> Element) -> Self {

        random(factory: Self.init, elementGenerator: elementGenerator)
    }
}

extension SetAlgebra where Self: Collection, Element: Randomizable {

    public static func random() -> Self {

        random(elementGenerator: Element.random)
    }
}

extension SetAlgebra where Self: Collection, Element: RangeRandomizable {

    public static func random(elementRange: ClosedRange<Element>) -> Self {

        random(elementGenerator: { Element.random(in: elementRange) })
    }
}

extension Dictionary {

    public static func random(elementGenerator: @escaping () -> Element) -> Self {

        random(factory: { generator in

            var result = Dictionary()

            for element in generator {
                result[element.key] = element.value
            }

            return result

        }, elementGenerator: elementGenerator)
    }
}

extension Dictionary where Key: Randomizable, Value: Randomizable {

    public static func random() -> Self {

        random(elementGenerator: { Element(key: Key.random(), value: Value.random()) })
    }
}