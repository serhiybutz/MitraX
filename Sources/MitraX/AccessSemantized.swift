//
//  AccessSemantized.swift
//  MitraX
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public struct AccessSemantized<P: Accessed, S: AccessSemantics>: Borrowable {
    // MARK: - State

    @usableFromInline
    let p: P

    // MARK: - Initialization

    @inline(__always)
    public init(_ property: P) {
        self.p = property
    }

    // MARK: - Borrowable

    @inline(__always)
    public var property: Accessed { p }

    @inline(__always)
    public var accessSemantics: AccessSemantics.Type { S.self }
}
