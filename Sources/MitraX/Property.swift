//
//  Property.swift
//  MitraX
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol AccessedProperty: Accessed {
    associatedtype ValueType
}

/// Shared property (memory location) which needs to be invariant to multiple threads.
public final class Property<T>: AccessedProperty {
    public typealias ValueType = T

    // MARK: - State

    @usableFromInline
    var value: T

    public var propId: UInt?

    @usableFromInline
    let sharedManager: SharedManager

    // MARK: - Initialization

    @inlinable
    public init(value: T, sharedManager: SharedManager) {
        self.value = value
        self.sharedManager = sharedManager
        sharedManager.registerProperty(self)
    }

    deinit {
        sharedManager.unregisterProperty(self)
    }
}

extension Property: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        value.description
    }
}
