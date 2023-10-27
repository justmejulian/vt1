//
//  SensorData.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 22.10.2023.
//

import Foundation
import SwiftData

@Model
class SensorData {
    var timestamp: Date
    var sensor_id: String
    var x: Double
    var y: Double
    var z: Double
    
    init(timestamp: Date, sensor_id: String, x: Double, y: Double, z: Double) {
        self.timestamp = timestamp
        self.sensor_id = sensor_id
        self.x = x
        self.y = y
        self.z = z
    }
}
