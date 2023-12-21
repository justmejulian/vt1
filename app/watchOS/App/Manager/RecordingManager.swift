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
    
    func start(exercise: String) throws -> RecordingData {
        
        if (isRecording) {
            throw RecordingError("Recording already running")
        }
        
        print("start recording")
        
        isRecording = true 

        let startDate = Date()
        
        return RecordingData(exercise: exercise, startTimestamp: startDate);
    }
    
    func stop() {
        isRecording = false
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func monitorUpdates(recording: RecordingData, handleUpdate: @escaping (_ sensorData: SensorData) -> Void) async throws {
        print("Monitoring Updates")
        let startDate = recording.startTimestamp
        
        guard CMBatchedSensorManager.isAccelerometerSupported && CMBatchedSensorManager.isDeviceMotionSupported else {
            throw RecordingError("Error CMBatchedSensorManager not supported")
        }
        
        self.motionManager.startAccelerometerUpdates()
        self.motionManager.startDeviceMotionUpdates()
        
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
            throw RecordingError("Failed to start accelerometerUpdates")
        }

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
                let date = startDate.addingTimeInterval(firstValue.timestamp)
                
                let rotationRateSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "rotationRate", values: rotationRateValues)
                handleUpdate(rotationRateSensorData)

                let userAccelerationSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "userAcceleration", values: userAccelerationValues)
                handleUpdate(userAccelerationSensorData)

                let gravitySensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "gravity", values: gravityValues)
                handleUpdate(gravitySensorData)
            }
            throw RecordingError("Failed to start deviceMotionUpdates")
        } catch {
            print("Error handling deviceMotionUpdates", error)
            throw RecordingError("Failed to start deviceMotionUpdates")
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
