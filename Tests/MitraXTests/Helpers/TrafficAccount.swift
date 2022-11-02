//
//  TrafficAccount.swift
//  MitraX
//
//  Created by Serhiy Butz on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import MitraX

/// A fictional traffic consumer account (an example of MitraX's Shared Manager usage)
struct TrafficAccount {
    private let sharedManager: SharedManager

    // MARK: - Properties (State)

    private let balance: Property<Double> // remaining money
    private let traffic: Property<Double> // traffic consumed

    // MARK: - Initialization

    init() {
        sharedManager = SharedManager()
        balance = Property<Double>(value: 0, sharedManager: sharedManager)
        traffic = Property<Double>(value: 0, sharedManager: sharedManager)
    }

    // MARK: - Queries

    public var currentBalance: Double {
        sharedManager.borrow(balance.ro) { $0.value }
    }
    public var currentTraffic: Double {
        sharedManager.borrow(traffic.ro) { $0.value }
    }
    public var summary: (balance: Double, traffic: Double) {
        sharedManager.borrow(balance.ro, traffic.ro) { (balance: $0.value, traffic: $1.value) }
    }

    // MARK: - Commands

    public func topUp(for amount: Double) {
        sharedManager.borrow(balance.rw) { $0.value += amount }
    }
    public func consume(_ gb: Double, at costPerGb: Double) -> Double {
        sharedManager.borrow(balance.rw, traffic.rw) { balance, traffic in
            let cost = gb * costPerGb
            let spent = balance.value < cost ? balance.value : cost
            balance.value -= spent
            let consumed = spent / costPerGb
            traffic.value += consumed
            return consumed
        }
    }
}
