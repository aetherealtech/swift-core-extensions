//
// Created by Daniel Coleman on 2/19/22.
//

import Foundation

public class ReadWriteLock {

    public init() {

    }

    public func lock<R>(_ work: () throws -> R) rethrows -> R {

        try queue.sync(execute: work)
    }

    public func exclusiveLock<R>(_ work: () throws -> R) rethrows -> R {

        try queue.sync(flags: [.barrier], execute: work)
    }

    private let queue = DispatchQueue(label: "com.aetherealtech.eventstreams.readwritelock", attributes: [.concurrent])
}