//
//  SensorData.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 22.10.2023.
//

import Foundation
import SwiftData

@Model
class SensorData: Codable{

    enum CodingKeys: CodingKey {
        case recordingStart
        case timestamp
        case sensor_id
        case x
        case y
        case z
    }

    var recordingStart: Date
    var timestamp: Date
    var sensor_id: String // todo rename to camelcase
    var x: Double
    var y: Double
    var z: Double
    
    init(recordingStart: Date, timestamp: Date, sensor_id: String, x: Double, y: Double, z: Double) {
        self.recordingStart = recordingStart
        self.timestamp = timestamp
        self.sensor_id = sensor_id
        self.x = x
        self.y = y
        self.z = z
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recordingStart = try container.decode(Date.self, forKey: .recordingStart)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.sensor_id = try container.decode(String.self, forKey: .sensor_id)
        self.x = try container.decode(Double.self, forKey: .x)
        self.y = try container.decode(Double.self, forKey: .y)
        self.z = try container.decode(Double.self, forKey: .z)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recordingStart, forKey: .recordingStart)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(sensor_id, forKey: .sensor_id)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(z, forKey: .z)
    }
}
