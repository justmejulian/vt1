//
//  SensorData.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 229.10.2023.
//

import Foundation
import SwiftData

@Model
class SensorData: Codable{

    enum CodingKeys: CodingKey {
        case recordingStart
        case timestamp
        case sensor_id
        case values
    }

    var recordingStart: Date
    var timestamp: Date
    var sensor_id: String // todo rename to camelcase

    var values: [Value] // batch of values

    init(recordingStart: Date, timestamp: Date, sensor_id: String, values: [Value]) {
        self.recordingStart = recordingStart
        self.timestamp = timestamp
        self.sensor_id = sensor_id
        self.values = values
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recordingStart = try container.decode(Date.self, forKey: .recordingStart)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.sensor_id = try container.decode(String.self, forKey: .sensor_id)
        self.values = try container.decode([Value].self, forKey: .values)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recordingStart, forKey: .recordingStart)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(sensor_id, forKey: .sensor_id)
        try container.encode(values, forKey: .values)
    }
}

struct Value: Codable {
    var x: Double
    var y: Double
    var z: Double
    var timestamp: TimeInterval
}
