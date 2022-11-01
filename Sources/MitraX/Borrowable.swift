//
//  Borrowable.swift
//  MitraX
//
//  Created by Serhiy Butz on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol Borrowable {
    var property: Accessed { get }
    var accessSemantics: AccessSemantics.Type { get }
}

extension Array where Element == Borrowable {
    @inline(__always)
    var hasRWAccessSemantics: Bool {
        contains { $0.accessSemantics == RWAccessSemantics.self }
    }
    @inline(__always)
    var withRWAccessSemantics: Self {
        filter { $0.accessSemantics == RWAccessSemantics.self }
    }
}
