//
//  Bank.swift
//  MitraX
//
//  Created by Serge Bouts on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import MitraX

/// A fictional Bank (an example of MitraX's Shared Manager usage)
struct Bank {
    let sharedManager: SharedManager

    static let accountCount = 5
    static let initialBalance = 50

    // MARK: - Properties (State)

    let accounts: [Property<Int>]

    // MARK: - Initialization

    init() {
        sharedManager = SharedManager()
        var acnts: [Property<Int>] = []
        for _ in 0..<BankMock.accountCount {
            acnts.append(Property(value: BankMock.initialBalance, sharedManager: sharedManager))
        }
        self.accounts = acnts
    }

    // MARK: - Commands

    func transfer(from fromAccount: Int, to toAccount: Int, amount: Int) {
        precondition(accounts.indices ~= fromAccount)
        precondition(accounts.indices ~= toAccount)
        sharedManager.borrow(
            accounts[fromAccount].rw,
            accounts[toAccount].rw)
        { from, to in
            // Note: races for non-overlapping fromAccount->toAccount pairs are allowed!
            from.value -= amount
            to.value += amount

            // simulate some work
            let sleepVal = arc4random() & 15
            usleep(sleepVal)
        }
    }

    // MARK: - Queries

    func report() -> [Int] {
        sharedManager.borrow(accounts[0].ro, accounts[1].ro, accounts[2].ro, accounts[3].ro, accounts[4].ro) {
            return [$0.value, $1.value, $2.value, $3.value, $4.value]
        }
    }
}
