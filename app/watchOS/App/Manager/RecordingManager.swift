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

@MainActor
class RecordingManager: NSObject, ObservableObject {
    @Published private(set) var isRecording = false
    
    private let motionManager = MotionManager()
    
    func start(exercise: String) throws -> Recording {
        Logger.viewCycle.debug("Calling start RecordingManager")
        
        if (isRecording) {
            throw RecordingError("Recording already running")
        }
        
        Logger.viewCycle.info("Starting recording")
        
        isRecording = true
        
        let startDate = Date()
        
        return Recording(exercise: exercise, startTimestamp: startDate);
    }
    
    func stop() {
        Logger.viewCycle.debug("Calling stop RecordingManager")
        isRecording = false
        Task.detached {
            await self.motionManager.stopUpdates()
        }
    }
    
    func monitorUpdates(recording: Recording, handleUpdate: @escaping @Sendable (_ recordingStart: Date, _ timestamp: Date, _ sensor_id: String, _ values: [Value]) -> Void) async throws {
        Logger.viewCycle.debug("Started Monitoring Updates")
        
        // todo repace with recording id
        let startDate = recording.startTimestamp
        
        Task.detached {
            @Sendable
            func handleUpdatesWithStartDate(_ timestamp: Date, _ sensor_id: String, _ values: [Value]) {
                handleUpdate(startDate, timestamp, sensor_id, values)
            }
            
            do {
                try await self.motionManager.startUpdates(handleUpdate: handleUpdatesWithStartDate)
            } catch {
                Logger.viewCycle.error("Error starting updates: \(error)")
            }
        }
        
    }
}

// can be run on diffetent Thread
private actor MotionManager {
    let motionManager = CMBatchedSensorManager()
    
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }

    
    func startUpdates(handleUpdate: @escaping @Sendable (_ timestamp: Date, _ sensor_id: String, _ values: [Value]) -> Void) throws {
        guard CMBatchedSensorManager.isAccelerometerSupported && CMBatchedSensorManager.isDeviceMotionSupported else {
            throw RecordingError("Error CMBatchedSensorManager not supported")
        }
        
        motionManager.startAccelerometerUpdates(handler: { (batchedData, error) in
            if let error = error {
                Logger.viewCycle.error("Error starting AccelerometerUpdates: \(error.localizedDescription)")
                return
            }
            
            guard let batchedData = batchedData else {
                Logger.viewCycle.error("Error starting AccelerometerUpdates: did not recive any data")
                return
            }
            self.consumeAccelerometerUpdates(batchedData: batchedData, handleUpdate: handleUpdate)
        })
        
        motionManager.startDeviceMotionUpdates(handler: { (batchedData, error) in
            if let error = error {
                Logger.viewCycle.error("Error starting DeviceMotionUpdate: \(error.localizedDescription)")
                return
            }
            
            guard let batchedData = batchedData else {
                Logger.viewCycle.error("Error starting DeviceMotionUpdate: did not recive any data")
                return
            }
            self.consumeDeviceMotionUpdates(batchedData: batchedData, handleUpdate: handleUpdate)
        })
    }
    
    func consumeDeviceMotionUpdates(batchedData: [CMDeviceMotion], handleUpdate: @escaping @Sendable (_ timestamp: Date, _ sensor_id: String, _ values: [Value]) -> Void) {
        Logger.viewCycle.debug("DeviceMotionUpdate")
        
        // todo do all of this in a different thread
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
        
        handleUpdate(date, "rotationRate", rotationRateValues)
        
        handleUpdate(date, "userAcceleration", userAccelerationValues)
        
        handleUpdate(date, "gravity", gravityValues)
        
        handleUpdate(date, "quaternion", quaternionValues)
    }
    
    func consumeAccelerometerUpdates(batchedData: [CMAccelerometerData], handleUpdate: @escaping @Sendable (_ timestamp: Date, _ sensor_id: String, _ values: [Value]) -> Void) {
        Logger.viewCycle.debug("AccelerometerUpdate")
        var values: [Value] = []
        
        batchedData.forEach { data in
            values.append(Value(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z, timestamp: Date(timeIntervalSince1970: data.timestamp.timeIntervalSince1970)))
        }
        
        // all have differnt timestamps
        // use first as batch tiemstamp
        // The timestamp is the amount of time in seconds since the device booted.
        let firstValue = values.first!
        
        let date = Date(timeIntervalSince1970: firstValue.timestamp.timeIntervalSince1970)
        handleUpdate(date, "acceleration", values)
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
