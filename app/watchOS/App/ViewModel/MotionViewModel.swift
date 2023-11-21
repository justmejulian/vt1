//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import CoreMotion
import SwiftData
import HealthKit

class MotionViewModel: NSObject, ObservableObject {
    @ObservationIgnored
    private let connectivityManager = ConnectivityManager.shared

    @ObservationIgnored
    private let workoutManager = WorkoutManager.shared


    @ObservationIgnored
    private let dataSource = DataSource.shared

    // todo move to constants file
    // private static let accelerationSensor = "f1e8e57a-b350-4450-9d5a-4fc13410afcc"
    // private static let gyroscopeSensor = "c8ddbb1d-7395-4892-bc5e-30923b7c0de4"
    private static let accelerationSensor = "Acceleration"
    private static let gyroscopeSensor = "Gyroscope"

    @Published private(set) var isRecording = false

    struct BaseData {
        var x = 0.0
        var y = 0.0
        var z = 0.0
    }

    @Published var acceleration = BaseData()
    @Published var gyroscope = BaseData()

    let motionManager = CMBatchedSensorManager()

    @Published var timeCounter = 0

    var timer: Timer? = nil

    private func toggleTimer() {
        if timer == nil {
            // Start the timer
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                // Update the counter every second
                self.timeCounter += 1
            }
        } else {
            // Stop the timer
            timer?.invalidate()
            timer = nil
        }
    }

    private func start() {
        // todo exercise name, default or what comes from iphone
        print("start recording")
        Task {
            try await workoutManager.startWorkout()
            self.recordAndSendData()
            isRecording = true
        }
    }

    // todo this function should throw
    func recordAndSendData() {
        print("recording and sending Data")

        let startDate = Date()
        let recording = RecordingData(exercise: "testSquat", startTimestamp: startDate)
        dataSource.appendRecording(recording)

        // todo stating and sending?
        self.sendRecording(recording)

        // todo make sure workout is running
        Task {
            do {
                print("recording acceleration")
                for try await batchedData in self.motionManager.accelerometerUpdates() {
                    var values: [Value] = []
                    batchedData.forEach { data in
                        values.append(Value(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z, timestamp: data.timestamp))
                    }
                    // print("acceleration", batchedData.count)
                    let firstValue = values.first!
                    // todo do they all have the same timestamp?
                    let date = startDate.addingTimeInterval(firstValue.timestamp)
                    self.acceleration = BaseData(x: firstValue.x, y: firstValue.y, z: firstValue.z)
                    let acceSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: MotionViewModel.accelerationSensor, values: values)
                    self.dataSource.appendSensorData(acceSensorData)
                    self.sendSensorData(acceSensorData)
                }
            } catch {
                print(error)
                print("\(error)")
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
                    // print("gyroscope", batchedData.count)
                    // todo catch no value
                    let firstValue = values.first!
                    // todo do they all have the same timestamp?
                    let date = startDate.addingTimeInterval(firstValue.timestamp)
                    self.gyroscope = BaseData(x: firstValue.x, y: firstValue.y, z: firstValue.z)
                    let gyroSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: MotionViewModel.gyroscopeSensor, values: values)
                    //print("Adding gyro data to recording")
                    self.dataSource.appendSensorData(gyroSensorData)
                    self.sendSensorData(gyroSensorData)
                }
            } catch {
                print("\(error)")
            }
        }
    }

    func sendSensorData(_ data: SensorData){
        self.connectivityManager.sendSensorData(sensorData: data)
    }

    func sendRecording(_ data: RecordingData){
        self.connectivityManager.sendRecording(recording: data)
    }

    func sync() {
        print("syncing")
        let sensorData = dataSource.fetchSensorDataArray()
        let recordings = dataSource.fetchRecordingArray()

        print("Syncing \(sensorData.count) SensorData and \(recordings.count) Recordings")
        sensorData.forEach { sensorData in
            connectivityManager.sendSensorData(sensorData: sensorData)
        }
        recordings.forEach { recordingData in
            connectivityManager.sendRecording(recording: recordingData)
        }
        print("Finished syncing")
    }

    private func stop() {
        timeCounter = 0
        isRecording = false
        acceleration = BaseData()
        gyroscope = BaseData()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
    }

    func toggle() {
        toggleTimer()

        if isRecording {
            stop()
            sync()
            return
        }

        start()
    }

    func getCountOfUnsyncedData() -> Int? {
        if isRecording {
            print("Cannot get count of unsynced data while recording")
            return nil
        }
        return getCountOfUnsyncedSensorData()! + getCountOfUnsyncedRecordingData()!
    }

    func getCountOfUnsyncedSensorData() -> Int? {
        if isRecording {
            print("Cannot get count of unsynced sensor data while recording")
            return nil
        }
        return dataSource.fetchSensorDataArray().count
    }
    func getCountOfUnsyncedRecordingData() -> Int? {
        if isRecording {
            print("Cannot get count of unsynced recording data while recording")
            return nil
        }
        return dataSource.fetchRecordingArray().count
    }
}
