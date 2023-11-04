//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import CoreMotion

class MotionViewModel: ObservableObject {
    
    private static let accelerationSensor = "f1e8e57a-b350-4450-9d5a-4fc13410afcc"
    private static let gyroscopeSensor = "c8ddbb1d-7395-4892-bc5e-30923b7c0de4"
    
    @Published private(set) var isRecording = false
    
    struct BaseData {
        var x = 0.0
        var y = 0.0
        var z = 0.0
        mutating func set(x: Double, y:Double, z:Double){
            self.x = x
            self.y = y
            self.z = z
        }
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

    init() {
    }
    
    private func start(){
        let recording = RecordingData(exercise: "testSquat")

        self.isRecording = true

        let motionManager = CMMotionManager()
        
        let date = Date()

        print("Adding data to context")
        print(motionManager.isAccelerometerAvailable)
        print(motionManager.isGyroAvailable)
        print(motionManager.isDeviceMotionAvailable)

        if motionManager.isAccelerometerAvailable {
            //todo use 0.1 for display, but store more than that
            motionManager.accelerometerUpdateInterval = 0.1
            
            motionManager.startAccelerometerUpdates(to: .main) { data, error in
                if let data = data {
                    print(data)
                    self.acceleration.set(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
                    let acceSensorData = SensorData(timestamp: date, sensor_id: MotionViewModel.accelerationSensor, x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
                    print("Adding acc data to recording")
                    recording.sensorData.append(acceSensorData)
                }
            }
        } else {
            print("Acc not availibe")
        }

        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { data, error in
                if let data = data {
                    print(data)
                    self.acceleration.set(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                    let gyroSensorData = SensorData(timestamp: date, sensor_id: MotionViewModel.gyroscopeSensor, x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                    print("Adding gyro data to recording")
                    recording.sensorData.append(gyroSensorData)
                }
            }
        } else {
            print("Gyro not availibe")
        }
    }
    
    private func stop() {
        isRecording = false
        acceleration = BaseData()
        gyroscope = BaseData()
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
