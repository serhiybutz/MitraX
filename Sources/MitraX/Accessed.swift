//
//  Accessed.swift
//  MitraX
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol Accessed: AnyObject {
    var propId: UInt? { get set }
}

extension Accessed {
    // MARK: - Access Semantics UI

    @inlinable @inline(__always)
    public var ro: AccessSemantized<Self, ROAccessSemantics> {
        AccessSemantized(self)
    }

    @inlinable @inline(__always)
    public var rw: AccessSemantized<Self, RWAccessSemantics> {
        AccessSemantized(self)
    }
}
