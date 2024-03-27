//
//  RecordingManager.swift
//  vt1
//
//  Created by Julian Visser on 24.11.2023.
//

import Foundation
import CoreMotion
import SwiftUI
import OSLog

class RecordingManager: NSObject, ObservableObject {
    let motionManager = CMBatchedSensorManager()
    
    @Published private(set) var isRecording = false
    
    func start(exercise: String) throws -> RecordingData {
        Logger.viewCycle.debug("Calling start RecordingManager")
        
        if (isRecording) {
            throw RecordingError("Recording already running")
        }
        
        Logger.viewCycle.info("Starting recording")
        
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
        Logger.viewCycle.debug("Started Monitoring Updates")
        let startDate = recording.startTimestamp
        
        guard CMBatchedSensorManager.isAccelerometerSupported && CMBatchedSensorManager.isDeviceMotionSupported else {
            throw RecordingError("Error CMBatchedSensorManager not supported")
        }
        
        self.motionManager.startAccelerometerUpdates()
        self.motionManager.startDeviceMotionUpdates()
        
        Task {
            do {
                Logger.viewCycle.debug("Starting accelerometerUpdates")
                for try await batchedData in self.motionManager.accelerometerUpdates() {
                    var values: [Value] = []
                    
                    batchedData.forEach { data in
                        values.append(Value(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z, timestamp: Date(timeIntervalSince1970: data.timestamp.timeIntervalSince1970)))
                    }
                    
                    // all have differnt timestamps
                    // use first as batch tiemstamp
                    // The timestamp is the amount of time in seconds since the device booted.
                    let firstValue = values.first!
                    
                    let date = Date(timeIntervalSince1970: firstValue.timestamp.timeIntervalSince1970)
                    
                    let sensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "acceleration", values: values)
                    
                    handleUpdate(sensorData)
                }
            } catch {
                Logger.viewCycle.error("Error handling accelerometerUpdates \(error)")
                throw RecordingError("Failed to start accelerometerUpdates")
            }
        }
        

        Task {
            do {
                Logger.viewCycle.debug("Starting deviceMotionUpdates")
                for try await batchedData in self.motionManager.deviceMotionUpdates() {
                    var rotationRateValues: [Value] = []
                    var userAccelerationValues: [Value] = []
                    var gravityValues: [Value] = []
                    var quaternionValues: [Value] = []
                    
                    batchedData.forEach { data in
                        let dataDate = Date(timeIntervalSince1970: data.timestamp.timeIntervalSince1970);
                        rotationRateValues.append(Value(x:data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z, timestamp: dataDate))
                        userAccelerationValues.append(Value(x:data.userAcceleration.x, y: data.userAcceleration.y, z: data.userAcceleration.z, timestamp: dataDate))
                        gravityValues.append(Value(x:data.gravity.x, y: data.gravity.y, z: data.gravity.z, timestamp: dataDate))
                        quaternionValues.append(Value(x:data.attitude.quaternion.x, y: data.attitude.quaternion.y, z: data.attitude.quaternion.z, w: data.attitude.quaternion.w, timestamp: dataDate))
                    }
                    
                    let firstValue = rotationRateValues.first!
                    
                    let date = Date(timeIntervalSince1970: firstValue.timestamp.timeIntervalSince1970)
                    
                    let rotationRateSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "rotationRate", values: rotationRateValues)
                    handleUpdate(rotationRateSensorData)

                    let userAccelerationSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "userAcceleration", values: userAccelerationValues)
                    handleUpdate(userAccelerationSensorData)

                    let gravitySensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "gravity", values: gravityValues)
                    handleUpdate(gravitySensorData)
                    
                    let quaternionSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: "quaternion", values: quaternionValues)
                    handleUpdate(quaternionSensorData)
                }
            } catch {
                Logger.viewCycle.error("Error handling deviceMotionUpdates \(error)")
                throw RecordingError("Failed to start deviceMotionUpdates")
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
