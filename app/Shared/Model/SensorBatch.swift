//
//  vt1
//
//  Created by Julian Visser on 25.10.2023.
//

import Foundation
import SwiftData

@Model
class SensorBatch {
    var recordingStart: Date
    var timestamp: Date
    var sensor_id: String

    var values: [Value] // batch of values

    init(recordingStart: Date, timestamp: Date, sensor_id: String, values: [Value]) {
        self.recordingStart = recordingStart
        self.timestamp = timestamp
        self.sensor_id = sensor_id
        self.values = values
    }
    
    init(sensorBatchStruct: SensorBatchStruct){
        self.recordingStart = sensorBatchStruct.recordingStart
        self.timestamp = sensorBatchStruct.timestamp
        self.sensor_id = sensorBatchStruct.sensor_id
        self.values = sensorBatchStruct.values
    }
}

struct SensorBatchStruct: Codable {
    enum CodingKeys: CodingKey {
        case recordingStart
        case timestamp
        case sensor_id
        case values
    }

    var id: PersistentIdentifier?
    var recordingStart: Date
    var timestamp: Date
    var sensor_id: String

    var values: [Value] // batch of values
    
    init(recordingStart: Date, timestamp: Date, sensor_id: String, values: [Value]) {
        self.recordingStart = recordingStart
        self.timestamp = timestamp
        self.sensor_id = sensor_id
        self.values = values
    }
    
    init(sensorBatch: SensorBatch){
        self.id = sensorBatch.persistentModelID
        self.recordingStart = sensorBatch.recordingStart
        self.timestamp = sensorBatch.timestamp
        self.sensor_id = sensorBatch.sensor_id
        self.values = sensorBatch.values
    }
    // -- Codable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recordingStart = try container.decode(Date.self, forKey: .recordingStart)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.sensor_id = try container.decode(String.self, forKey: .sensor_id)
        self.values = try container.decode([Value].self, forKey: .values)
    }

    // We don't want the id in the encoding
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
    var w: Double?

    var timestamp: Date

    init(x: Double, y: Double, z: Double, timestamp: Date) {
        self.x = x
        self.y = y
        self.z = z
        self.w = nil
        self.timestamp = timestamp
    }

    init(x: Double, y: Double, z: Double, w: Double, timestamp: Date) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
        self.timestamp = timestamp
    }
}
