import Foundation

extension Result: @retroactive Decodable where Success: Decodable, Failure == Error {
    public init(from decoder: Decoder) throws {
        self.init { try Success(from: decoder) }
    }
}
