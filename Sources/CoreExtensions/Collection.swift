//
//  Created by Daniel Coleman on 1/10/22.
//

import Foundation

extension Collection {

    public func compact() -> [Element.Wrapped] where Element: OptionalProtocol {
        
        self
            .filter { value in value != nil }
            .map { value in value.unsafelyUnwrapped }
    }
}

extension Collection {

    public func flatten() -> [Element.Element] where Element: Collection, Element.Index == Index {
        
        self
            .flatMap { value in value }
    }
}
