//
// Created by Daniel Coleman on 2/19/22.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension DispatchGroup {

    public func waitAsync(queue: DispatchQueue = DispatchQueue.global()) async {

        await withCheckedContinuation { continuation in

            self.notify(queue: queue) {

                continuation.resume()
            }
        }
    }
}