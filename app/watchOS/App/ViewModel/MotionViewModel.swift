//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import CoreMotion
import SwiftData

class MotionViewModel: ObservableObject {
    private let connectivityManager = ConnectivityManager()


    // todo move to constants file
    // private static let accelerationSensor = "f1e8e57a-b350-4450-9d5a-4fc13410afcc"
    // private static let gyroscopeSensor = "c8ddbb1d-7395-4892-bc5e-30923b7c0de4"
    private static let accelerationSensor = "Acceleration"
    private static let gyroscopeSensor = "Gyroscope"

    @Published private(set) var isRecording = false

    @ObservationIgnored
    private let dataSource: DataSource

    // Use batchedSensor
    private let motionManager = CMMotionManager()

    struct BaseData {
        var x = 0.0
        var y = 0.0
        var z = 0.0
    }

    @Published var acceleration = BaseData()

    @Published var gyroscope = BaseData()
    
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

    init(dataSource: DataSource = DataSource.shared) {
        self.dataSource = dataSource
    }

    private func start(){
        let startRecording = Date()
        let recording = RecordingData(exercise: "testSquat", startTimestamp: startRecording)
        dataSource.appendRecording(recording)
        self.sendRecording(recording)

        self.isRecording = true

        print("Adding data to context")
        if motionManager.isDeviceMotionAvailable {
            // todo set to max
            motionManager.deviceMotionUpdateInterval = 0.1

            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                if let data = data {
                    let date = Date()
                    self.acceleration = BaseData(x: data.userAcceleration.x, y: data.userAcceleration.y, z: data.userAcceleration.z)
                    let acceSensorData = SensorData(recordingStart: startRecording, timestamp: date, sensor_id: MotionViewModel.accelerationSensor, x: data.userAcceleration.x, y: data.userAcceleration.y, z: data.userAcceleration.z)

                    self.gyroscope = BaseData(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                    let gyroSensorData = SensorData(recordingStart: startRecording, timestamp: date, sensor_id: MotionViewModel.gyroscopeSensor, x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)

                    //print("Adding gyro data to recording")
                    self.dataSource.appendSensorData(gyroSensorData)
                    self.sendSensorData(gyroSensorData)

                    //print("Adding acceleration data to recording")
                    self.dataSource.appendSensorData(acceSensorData)
                    self.sendSensorData(acceSensorData)
                }
                if let error = error {
                    print(error)
                }
            }

        } else {
            print("Device Motion is not Available")
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
    }

    private func stop() {
        timeCounter = 0
        isRecording = false
        acceleration = BaseData()
        gyroscope = BaseData()
        motionManager.stopDeviceMotionUpdates()
    }
    
    func toggle() {
        toggleTimer()
        if isRecording {
            stop()
        } else {
            start()
        }
    }
}
