//
//  Created by Julian Visser on 25.10.2023.
//

import Foundation
import SwiftData

@Model
class RecordingData {
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
}
