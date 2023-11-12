//
//  UnsyncedData.swift
//  vt1
//
//  Created by Julian Visser on 07.11.2023.
//

import Foundation
import SwiftData

@Model
class SyncedData {
    var recoridngs: [RecordingData]
    var sensorData: [SensorData]
    
    init () {
        self.recoridngs = []
        self.sensorData = []
    }
    init(recoridngs: [RecordingData], sensorData: [SensorData]) {
        self.recoridngs = recoridngs
        self.sensorData = sensorData
    }

    init(recoridngs: [RecordingData]) {
        self.recoridngs = recoridngs
        self.sensorData = []
    }

    init(sensorData: [SensorData]) {
        self.recoridngs = []
        self.sensorData = sensorData
    }
}
