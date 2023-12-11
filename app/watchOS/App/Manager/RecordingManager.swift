//
//  RecordingManager.swift
//  vt1
//
//  Created by Julian Visser on 24.11.2023.
//

import Foundation
import CoreMotion
import SwiftUI

class RecordingManager: NSObject, ObservableObject {
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
        
        guard CMBatchedSensorManager.isAccelerometerSupported && CMBatchedSensorManager.isDeviceMotionSupported else {
            print("Error CMBatchedSensorManager not supported")
            return
        }
        
        Task {
            do {
                for try await batchedData in self.motionManager.accelerometerUpdates() {
                    
                    var values: [Value] = []
                    batchedData.forEach { data in
                        values.append(Value(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z, timestamp: data.timestamp))
                    }
                    
                    let firstValue = values.first!
                    let date = startDate.addingTimeInterval(firstValue.timestamp)
                    
                    let sensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "acceleration", values: values)
                    
                    handleUpdate(sensorData)
                }
            } catch {
                print("Error handling accelerometerUpdates", error)
            }
        }
        
        Task {
            do {
                for try await batchedData in self.motionManager.deviceMotionUpdates() {
                    
                    var rotationRateValues: [Value] = []
                    var userAccelerationValues: [Value] = []
                    var gravityValues: [Value] = []
                    batchedData.forEach { data in
                        rotationRateValues.append(Value(x:data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z, timestamp: data.timestamp))
                        userAccelerationValues.append(Value(x:data.userAcceleration.x, y: data.userAcceleration.y, z: data.userAcceleration.z, timestamp: data.timestamp))
                        gravityValues.append(Value(x:data.gravity.x, y: data.gravity.y, z: data.gravity.z, timestamp: data.timestamp))
                    }
                    
                    let firstValue = rotationRateValues.first!
                    // todo do they all have the same timestamp?
                    let date = startDate.addingTimeInterval(firstValue.timestamp)
                    
                    let rotationRateSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "rotationRate", values: rotationRateValues)
                    handleUpdate(rotationRateSensorData)

                    let userAccelerationSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "userAcceleration", values: userAccelerationValues)
                    handleUpdate(userAccelerationSensorData)

                    let gravitySensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "gravity", values: gravityValues)
                    handleUpdate(gravitySensorData)
                }
            } catch {
                print("Error handling deviceMotionUpdates", error)
            }
        }
    }
}

struct RecordingError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}
