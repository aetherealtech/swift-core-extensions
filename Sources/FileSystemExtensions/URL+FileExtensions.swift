import Foundation

public enum RelativePathError: LocalizedError {
    case nonFileURL(URL)
    
    public var errorDescription: String? {
        switch self {
            case let .nonFileURL(url):
                return "\(url) is not a file URL"
        }
    }
}

// Original code written by Martin R. https://stackoverflow.com/a/48360631/78336

extension URL {
    func ensureIsFileURL() throws {
        guard isFileURL else {
            throw RelativePathError.nonFileURL(self)
        }
    }
    
    // Remove/replace "." and "..", make paths absolute
    var standardizedPathComponents: [String] {
        absoluteURL.standardizedFileURL.pathComponents
    }
}

public extension URL {
    func relativePath(from other: URL) throws -> String {
        // Ensure that both URLs represent files
        try ensureIsFileURL()
        try other.ensureIsFileURL()

        let destComponents = standardizedPathComponents
        let baseComponents = other.standardizedPathComponents

        // Find number of common path components
        let commonComponents = zip(destComponents, baseComponents)
            .lazy
            .prefix(while: ==)
            .count

        // Build relative path
        var relComponents = [String](
            repeating: "..",
            count: baseComponents.count - commonComponents
        )
        
        relComponents.append(contentsOf: destComponents[commonComponents...])
        return relComponents.joined(separator: "/")
    }
}
