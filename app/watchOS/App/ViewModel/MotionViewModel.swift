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
    private let dataSource = DataSource.shared

    // todo move to constants file
    // private static let accelerationSensor = "f1e8e57a-b350-4450-9d5a-4fc13410afcc"
    // private static let gyroscopeSensor = "c8ddbb1d-7395-4892-bc5e-30923b7c0de4"
    private static let accelerationSensor = "Acceleration"
    private static let gyroscopeSensor = "Gyroscope"

    @Published private(set) var isRecording = false

    // Use batchedSensor
    private let motionManager = CMBatchedSensorManager()

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

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

    private func start() async{
        let startDate = Date()
        // todo exercise name, default or what comes from iphone
        let recording = RecordingData(exercise: "testSquat", startTimestamp: startDate)
        dataSource.appendRecording(recording)
        self.sendRecording(recording)
        self.isRecording = true
        guard CMBatchedSensorManager.isAccelerometerSupported && CMBatchedSensorManager.isDeviceMotionSupported else {
            print("Error CMBatchedSensorManager nor supported, check permissions")
            return
        }
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .functionalStrengthTraining
        configuration.locationType = .indoor
        // Create the session and obtain the workout builder.
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            // Handle any exceptions.
            print(error)
            return
        }
        session?.delegate = self
        builder?.delegate = self
        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            Task {
                do {
                    for try await batchedData in CMBatchedSensorManager().accelerometerUpdates() {
                        batchedData.forEach { data in
                            // todo improve to send as batches
                            self.acceleration = BaseData(x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
                            let date = startDate.addingTimeInterval(data.timestamp)
                            let acceSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: MotionViewModel.accelerationSensor, x: data.acceleration.x, y: data.acceleration.y, z: data.acceleration.z)
                            //print("Adding acceleration data to recording")
                            self.dataSource.appendSensorData(acceSensorData)
                            self.sendSensorData(acceSensorData)
                        }
                    }
                } catch {
                    print(error)
                    print("\(error)")
                }
            }
            Task {
                do {
                    for try await batchedData in CMBatchedSensorManager().deviceMotionUpdates() {
                        batchedData.forEach { data in
                            // todo improve to send as batches
                            self.gyroscope = BaseData(x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                            let date = startDate.addingTimeInterval(data.timestamp)
                            let gyroSensorData = SensorData(recordingStart: startDate, timestamp: date, sensor_id: MotionViewModel.gyroscopeSensor, x: data.rotationRate.x, y: data.rotationRate.y, z: data.rotationRate.z)
                            //print("Adding gyro data to recording")
                            self.dataSource.appendSensorData(gyroSensorData)
                            self.sendSensorData(gyroSensorData)
                        }
                    }
                } catch {
                    print("\(error)")
                }
            }
        }
    }

    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            // Handle error.
            if error != nil {
                print(error!)
                return
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
        motionManager.stopDeviceMotionUpdates()
    }

    func toggle() async {
        toggleTimer()

        if isRecording {
            stop()
            sync()
            return
        }

        await start()
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

extension MotionViewModel: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {}
        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                        DispatchQueue.main.async {}
                }
            }
        }
    }
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
}

extension MotionViewModel: HKLiveWorkoutBuilderDelegate {

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
    }
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            let statistics = workoutBuilder.statistics(for: quantityType)
            // Update the published values.
        }
    }
}
