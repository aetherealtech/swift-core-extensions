//
// Created by Daniel Coleman on 2/19/22.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public class SignalEvent {

    public init() {

    }

    public func wait() async {

        guard !self.state.value.signaled else {
            return
        }
        
        await withCheckedContinuation { continuation in

            state.value.waiters.append(continuation)
        }
    }

    public func signal(reset: Bool = true) {

        let waiters = self.state.getAndSet { state in

                    state.waiters.removeAll()
                    state.signaled = !reset
                }.waiters

        for waiter in waiters {
            waiter.resume()
        }
    }

    public func reset() {

        state.value.signaled = false
    }

    private struct State {

        var signaled = false
        var waiters = [CheckedContinuation<Void, Never>]()
    }

    private var state = Atomic<State>(State())
}