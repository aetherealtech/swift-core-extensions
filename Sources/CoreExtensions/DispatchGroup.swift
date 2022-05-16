//
// Created by Daniel Coleman on 2/19/22.
//

import Foundation

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension DispatchGroup {

    public func waitAsync(queue: DispatchQueue = DispatchQueue.global()) async {

        await withCheckedContinuation { continuation in

            self.notify(queue: queue) {

                continuation.resume()
            }
        }
    }
}