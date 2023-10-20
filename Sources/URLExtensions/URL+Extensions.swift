import Foundation

public extension URL {
    static func data(
        _ data: Data,
        type: String
    ) -> URL {
        URL.data(
            data.base64EncodedString(),
            type: type,
            base64Encoded: true
        )
    }

    static func data(
        _ data: String,
        type: String,
        base64Encoded: Bool = false
    ) -> URL {
        let customAllowedSet = NSCharacterSet(charactersIn: " =&\"#%/<>?@\\^`{|}").inverted

        var prefix = "data:text/\(type)"
        if base64Encoded {
            prefix += ";base64"
        }

        return URL(string: "\(prefix),\(data.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!)")!
    }
}
