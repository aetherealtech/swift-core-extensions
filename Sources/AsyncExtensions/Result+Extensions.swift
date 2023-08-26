@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Result where Failure == Error {
    init(catching body: () async throws -> Success) async {
        do {
            self = try await .success(body())
        } catch {
            self = .failure(error)
        }
    }
}
