//
//  SharedManager.swift
//  MitraX
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

@usableFromInline
final class RevokeCondition {
    var revokeCond: NSCondition?
    var isRevoked: Bool = true

    var tid: UInt64? // non-nil value indicates that the "RevokeCondition" is in use

    let mutex = NSLock()

    // MARK: - UI

    @inline(__always)
    func await() {
        mutex.lock()
        defer { mutex.unlock() }

        if revokeCond == nil {
            revokeCond = NSCondition()
        }

        revokeCond!.lock()
        while !isRevoked {
            isRevoked = false
            guard revokeCond!.wait(until: Date().addingTimeInterval(5)) else {
                preconditionFailure("Awaiting a for conflicting borrowing timed out!")
            }
        } 
        revokeCond!.unlock()
    }

    @inline(__always)
    func revoke() {
        isRevoked = true
        tid = nil
        if let revokeCond = revokeCond {
            revokeCond.lock()
            defer { revokeCond.unlock() }
            revokeCond.broadcast()
        }
    }
}
