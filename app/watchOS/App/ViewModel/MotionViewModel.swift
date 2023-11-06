//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import CoreMotion
import SwiftData

class MotionViewModel: ObservableObject {
    private let connectivityManager = ConnectivityManager()
    
    private static let accelerationSensor = "f1e8e57a-b350-4450-9d5a-4fc13410afcc"
    private static let gyroscopeSensor = "c8ddbb1d-7395-4892-bc5e-30923b7c0de4"
    
    @Published private(set) var isRecording = false
    
    @ObservationIgnored
    private let dataSource: DataSource

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
        let recording = RecordingData(exercise: "testSquat")
        
        dataSource.appendRecoring(recording: recording)

        self.isRecording = true

        // todo could use the timestamp from deviceMotion
        let date = Date()

        print("Adding data to context")
        // todo why is gyro not availible
        print(motionManager.isDeviceMotionAvailable)
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                if let data = data {
                    // todo is the different to normal acceleration?
                    self.acceleration = BaseData(x: data.userAcceleration.x, y: data.userAcceleration.y, z: data.userAcceleration.z)
                    print(self.acceleration)
                    let acceSensorData = SensorData(timestamp: date, sensor_id: MotionViewModel.accelerationSensor, x: data.userAcceleration.x, y: data.userAcceleration.y, z: data.userAcceleration.z)

                    self.gyroscope = BaseData(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                    let gyroSensorData = SensorData(timestamp: date, sensor_id: MotionViewModel.gyroscopeSensor, x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)

                    print("Adding gyro data to recording")
                    recording.sensorData.append(gyroSensorData)
                    
                    print("Adding acceleration data to recording")
                    recording.sensorData.append(acceSensorData)
                }
                if let error = error {
                    print(error)
                }
            }

        } else {
            print("Device Motion is not Available")
        }
    }
    
    func sendMessageToiPhone() {
        let recordings = dataSource.fetchRecordings()
        connectivityManager.sendRecordings(recordings: recordings)
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
