//
//
//  File.swift
//  vt1
//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import CoreMotion

class GyroscopeData: ObservableObject {
    private let motionManager = CMMotionManager()

    @Published var x: Double = 0.0
    @Published var y: Double = 0.0
    @Published var z: Double = 0.0

    init() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1  // Set the update interval as needed
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                if let data = data {
                    self.xAcceleration = data.acceleration.x
                    self.yAcceleration = data.acceleration.y
                    self.zAcceleration = data.acceleration.z
                }
            }
        }
    }
}
