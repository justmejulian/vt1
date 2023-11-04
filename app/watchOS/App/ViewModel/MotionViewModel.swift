//
//  Created by Julian Visser on 17.10.2023.
//

import Foundation
import CoreMotion
import SwiftData

class MotionViewModel: ObservableObject {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    private static let accelerationSensor = "f1e8e57a-b350-4450-9d5a-4fc13410afcc"
    private static let gyroscopeSensor = "c8ddbb1d-7395-4892-bc5e-30923b7c0de4"
    
    @Published private(set) var isRecording = false
    
    private let motionManager = CMMotionManager()
    
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
        // todo do I need to catch?
        self.modelContainer = try! SwiftData.ModelContainer(for: RecordingData.self)
        self.modelContext = SwiftData.ModelContext(self.modelContainer)
    }
    
    private func start(){
        let recording = RecordingData(exercise: "testSquat")
        try? self.modelContext.save()

        self.isRecording = true

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
                    try? self.modelContext.save()
                }
                if let error = error {
                    print(error)
                }
            }
        } else {
            print("Acc not availibe")
        }

        if motionManager.isGyroAvailable {
            motionManager.gyroUpdateInterval = 0.1
            motionManager.startGyroUpdates(to: .main) { data, error in
                if let data = data {
                    self.gyroscope.set(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                    let gyroSensorData = SensorData(timestamp: date, sensor_id: MotionViewModel.gyroscopeSensor, x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                    print("Adding gyro data to recording")
                    recording.sensorData.append(gyroSensorData)
                    try? self.modelContext.save()
                }
                if let error = error {
                    print(error)
                }
            }
        } else {
            print("Gyro not availibe")
        }
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { data, error in
                if let data = data {
                    self.gyroscope.set(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                    let gyroSensorData = SensorData(timestamp: date, sensor_id: MotionViewModel.gyroscopeSensor, x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                    print("Adding gyro data to recording")
                    recording.sensorData.append(gyroSensorData)
                    try? self.modelContext.save()
                }
                if let error = error {
                    print(error)
                }
            }

        } else {
            print("Device Motion is not Available")
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
