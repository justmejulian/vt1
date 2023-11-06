//
//  Created by Julian Visser on 25.10.2023.
//

import Foundation
import SwiftData

@Model
class RecordingData: Codable{

    enum CodingKeys: CodingKey {
        case exercise
        case isSynced
        case sensorData
    }

    var exercise: String
    let isSynced: Bool
    var sensorData: [SensorData]
    
    init(exercise: String, isSynced: Bool, sensorData: [SensorData] = []) {
        self.exercise = exercise
        self.isSynced = isSynced
        self.sensorData = sensorData
    }
    
    init(exercise: String, sensorData: [SensorData] = []) {
        self.exercise = exercise
        self.isSynced = false
        self.sensorData = sensorData
    }
    
    // -- Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.exercise = try container.decode(String.self, forKey: .exercise)
        self.isSynced = try container.decode(Bool.self, forKey: .isSynced)
        self.sensorData = try container.decode([SensorData].self, forKey: .sensorData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(exercise, forKey: .exercise)
        try container.encode(isSynced, forKey: .isSynced)
        try container.encode(sensorData, forKey: .sensorData)
    }
}
