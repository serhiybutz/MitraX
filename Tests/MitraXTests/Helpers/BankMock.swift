//
//  BankMock.swift
//  MitraX
//
//  Created by Serhiy Butz on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import MitraX
import XConcurrencyKit

/// A fictional Bank's mock
struct BankMock {
    let sharedManager: SharedManager

    static let accountCount = 5
    static let initialBalance = 50

    // MARK: - Properties (State)

    let accounts: [Property<Int>]
    let raceDetector = RaceSensitiveSection()

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
            raceDetector.exclusiveCriticalSection({
                from.value -= amount
                to.value += amount

                // simulate some work
                let sleepVal = arc4random() & 15
                usleep(sleepVal)
            }, register: {
                $0(fromAccount)
                $0(toAccount)
            })
        }
    }

    // MARK: - Queries

    func report() -> [Int] {
        sharedManager.borrow(accounts[0].ro, accounts[1].ro, accounts[2].ro, accounts[3].ro, accounts[4].ro) { a0, a1, a2, a3, a4 in
            raceDetector.nonExclusiveCriticalSection({
                return [a0.value, a1.value, a2.value, a3.value, a4.value]
            }, register: { register in
                accounts.indices.forEach { register($0) }
            })
        }
    }
}
