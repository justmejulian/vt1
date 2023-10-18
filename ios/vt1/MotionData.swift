//
//  AccelerometerData.swift
//  vt1
//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import CoreMotion

class MotionData: ObservableObject {
    private let motionManager = CMMotionManager()

    struct motionData{
        var x: Double = 0.0
        var y: Double = 0.0
        var z: Double = 0.0
    }
    
    @Published var Acceleration = motionData.init()
    @Published var Gyroscope = motionData.init()
    
    init() {
        if motionManager.isAccelerometerAvailable {
            //todo use 0.1 for display, but store more than that
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                if let data = data {
                    self.Acceleration.x = data.acceleration.x
                    self.Acceleration.y = data.acceleration.y
                    self.Acceleration.z = data.acceleration.z
                }
            }
        }
        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { data, error in
                if let data = data {
                    self.Gyroscope.x = data.rotationRate.x
                    self.Gyroscope.y = data.rotationRate.y
                    self.Gyroscope.z = data.rotationRate.z
                }
            }
        }
    }
}

