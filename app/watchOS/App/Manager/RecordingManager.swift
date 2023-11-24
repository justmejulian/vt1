//
//  RecordingManager.swift
//  vt1
//
//  Created by Julian Visser on 24.11.2023.
//

import Foundation
import CoreMotion
import SwiftUI

struct RecordingError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}

class RecordingManager: NSObject, ObservableObject {
    static let shared = RecordingManager()

    let motionManager = CMBatchedSensorManager()
    
    @Published private(set) var isRecording = false
    
    func start() throws -> RecordingData {
        
        if (isRecording) {
            throw RecordingError("Recording already running")
        }
        
        print("start recording")
        
        isRecording = true

        let startDate = Date()
        
        return RecordingData(exercise: "testSquat", startTimestamp: startDate);
    }
    
    func stop() {
        isRecording = false
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func monitorUpdates(recording: RecordingData, handleUpdate: @escaping (_ sensorData: SensorData) -> Void) {
        
        let startDate = recording.startTimestamp
        
        Task {
            do {
                print("recording acceleration")
                for try await batchedData in self.motionManager.accelerometerUpdates() {
                    
                    var values: [Value] = []
                    batchedData.forEach { data in
                        values.append(Value(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z, timestamp: data.timestamp))
                    }
                    
                    let firstValue = values.first!
                    let date = startDate.addingTimeInterval(firstValue.timestamp)
                    
                    let sensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: Constants.accelerationSensor, values: values)
                    
                    handleUpdate(sensorData)
                }
            } catch {
                print("Error handeling accelerometerUpdates", error)
            }
        }
        
        Task {
            do {
                print("recording gyroscope")
                for try await batchedData in self.motionManager.deviceMotionUpdates() {
                    
                    var values: [Value] = []
                    batchedData.forEach { data in
                        values.append(Value(x:data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z, timestamp: data.timestamp))
                    }
                    
                    let firstValue = values.first!
                    // todo do they all have the same timestamp?
                    let date = startDate.addingTimeInterval(firstValue.timestamp)
                    
                    let sensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: Constants.gyroscopeSensor, values: values)
                    
                    handleUpdate(sensorData)
                }
            } catch {
                print("Error handeling deviceMotionUpdates", error)
            }
        }
    }
}
