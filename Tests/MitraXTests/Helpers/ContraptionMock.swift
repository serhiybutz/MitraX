//
//  ContraptionMock.swift
//  MitraX
//
//  Created by Serhiy Butz on 6/10/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import MitraX
import XConcurrencyKit

/// A fictional device `Contraption`'s mock.
struct ContraptionMock {
    let sharedManager: SharedManager

    let sensorReadingsRaceDetector = RaceSensitiveSection()

    // MARK: - Properties (State)

    let sensorReadings: [Property<Int>]
    private let average: Property<Double>

    // MARK: - Initialization

    init() {
        sharedManager = SharedManager()
        sensorReadings = [Property(value: 0, sharedManager: sharedManager),
                          Property(value: 0, sharedManager: sharedManager),
                          Property(value: 0, sharedManager: sharedManager)]
        average = Property<Double>(value: 0.0, sharedManager: sharedManager)
    }

    // MARK: - UI

    func updateSensor(_ i: Int, value: Int) {
        sharedManager.borrow(sensorReadings[i].rw) { sensor in
            sensorReadingsRaceDetector.exclusiveCriticalSection({
                sensor.value = value
            }, register: { $0(i) })
        }
    }

    @discardableResult
    func updateAvarage() -> Double {
        sharedManager.borrow(sensorReadings[0].ro, sensorReadings[1].ro, sensorReadings[2].ro, average.rw) { r0, r1, r2, average in
            sensorReadingsRaceDetector.nonExclusiveCriticalSection({
                average.value = Double(r0.value + r1.value + r2.value) / 3
                return average.value
            }, register: { register in (0..<3).indices.forEach { register($0) } })
        }
    }
}
