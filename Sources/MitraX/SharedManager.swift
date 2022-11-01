//
//  SharedManager.swift
//  MitraX
//
//  Created by Serhiy Butz on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

public final class SharedManager {
    // MARK: - Types

    @usableFromInline
    typealias Borrowing = (propsBits: UInt64, propsExclusiveBits: UInt64, revokeCondition: RevokeCondition)

    // MARK: - State

    @usableFromInline
    var properties: ContiguousArray<UInt> = []

    private var nextPropId: UInt = 0

    @usableFromInline
    func getNextPropId() -> UInt {
        nextPropId += 1
        return nextPropId - 1
    }

    private var revokeConditions: ContiguousArray<RevokeCondition> = []

    @usableFromInline
    var borrowings: ContiguousArray<Borrowing> = []

    @usableFromInline
    let mutex = NSLock()

    // MARK: - Initialization

    public init() {}

    // MARK: - UI

    @inlinable
    public func registerProperty(_ prop: Accessed) {
        precondition(properties.count <= MemoryLayout<UInt64>.size * 8)
        mutex.lock()
        defer { mutex.unlock() }
        prop.propId = getNextPropId()
        properties.append(prop.propId!)
    }

    @inlinable
    public func unregisterProperty(_ prop: Accessed) {
        mutex.lock()
        defer { mutex.unlock() }

        guard let propIndex = properties.firstIndex(where: { $0 == prop.propId }) else {
            return
        }

        properties.remove(at: propIndex)

        // Exempt propIndex's bit from the borrowings's bitwise values
        var newBorrowings: ContiguousArray<Borrowing> = []
        newBorrowings.reserveCapacity(borrowings.count)
        for b in borrowings {
            newBorrowings.append((propsBits: removeBit(n: propIndex, from: b.propsBits), propsExclusiveBits: removeBit(n: propIndex, from: b.propsExclusiveBits), revokeCondition: b.revokeCondition))
        }
        borrowings = newBorrowings
    }

    @usableFromInline @discardableResult
    func internalBorrow<R>(_ props: [Borrowable], accessBlock: () -> R) -> R {
        let tid = getThreadId()
        let revokeCondition = activateBorrowingFor(props, tid)
        defer {
            deactivateBorrowing(revokeCondition)
        }
        return accessBlock()
    }

    @usableFromInline @discardableResult
    func internalBorrow<R>(_ props: [Borrowable], accessBlock: () throws -> R) throws -> R {
        let tid = getThreadId()
        let revokeCondition = activateBorrowingFor(props, tid)
        defer {
            deactivateBorrowing(revokeCondition)
        }
        return try accessBlock()
    }

    // MARK: - Helpers

    @inline(__always)
    private func activateBorrowingFor(_ props: [Borrowable], _ tid: UInt64) -> RevokeCondition {
        let (propsBits, propsExclusiveBits) = makeBits(props, tid)
        while true {
            mutex.lock()
            if let index = borrowings.firstIndex(where: { $0.revokeCondition.tid! != tid && ((propsExclusiveBits & $0.propsBits | $0.propsExclusiveBits & propsBits) != 0) }) {
                let revokeCondition = revokeConditions[index]
                mutex.unlock()
                revokeCondition.await()
                continue
            } else { // Recycle revoke conditions
                // Bring the size of the revoke condition array to the size of the borrowing array increased by 1
                if revokeConditions.count <= borrowings.count {
                    (revokeConditions.count..<(borrowings.count + 1))
                        .forEach { _ in
                            revokeConditions.append(RevokeCondition())
                        }
                }
                let revokeCondition = revokeConditions.first(where: { $0.tid == nil })!
                revokeCondition.tid = tid
                borrowings.append((propsBits: propsBits, propsExclusiveBits: propsExclusiveBits, revokeCondition: revokeCondition))
                mutex.unlock()
                return revokeCondition // bail out
            }
        }
    }

    @inline(__always)
    private func makeBits(_ props: [Borrowable], _ tid: UInt64) -> (UInt64, UInt64) {
        var propsBits: UInt64 = 0 // accessed property bits
        var propsExclusiveBits: UInt64 = 0 // exclusively accessed property bits
        for i in props.indices {
            guard let propId = props[i].property.propId else {
                fatalError("Not registered property")
            }
            guard let propIndex = properties.firstIndex(of: propId) else {
                fatalError("Unknown property with id=\(propId)")
            }
            propsBits |= UInt64(1 << propIndex)

            if props[i].accessSemantics == RWAccessSemantics.self {
                propsExclusiveBits |= UInt64(1 << propIndex)
            }
        }
        return (propsBits, propsExclusiveBits)
    }

    @inline(__always)
    private func deactivateBorrowing(_ revokeCondition: RevokeCondition) {
        mutex.lock()
        revokeCondition.revoke()
        borrowings.removeAll { $0.revokeCondition === revokeCondition }

        mutex.unlock()
    }

    @inline(__always)
    private func getThreadId() -> UInt64 {
        var tid: UInt64 = 0
        pthread_threadid_np(nil, &tid)
        return tid
    }

    @usableFromInline @inline(__always)
    func removeBit(n: Int, from value: UInt64) -> UInt64 {
        let topMask = UInt64(~((1 << (n + 1)) - 1))
        let bottomMask = UInt64((1 << n) - 1)
        return (value & topMask) >> 1 | (value & bottomMask)
    }
}
