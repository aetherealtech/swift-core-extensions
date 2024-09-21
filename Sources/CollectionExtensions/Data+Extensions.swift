import Foundation

public extension Sequence<UInt8> {
    func string(encoding: String.Encoding) -> String? {
        .init(data: .init(self), encoding: encoding)
    }
}
