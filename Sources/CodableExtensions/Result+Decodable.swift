import Foundation

extension Result: @retroactive Decodable where Success: Decodable, Failure == any Error {
    public init(from decoder: Decoder) throws {
        self.init { try Success(from: decoder) }
    }
}
