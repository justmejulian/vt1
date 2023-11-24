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
    
    private let recordingManager = RecordingManager.shared

    @Published var timeCounter = 0

    var timer: Timer? = nil
    
    @Published var started = false

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
        print("start")
        
        started = true
        
        Task {
            try await workoutManager.startWorkout()
            do {
                let recording = try recordingManager.start()
                dataSource.appendRecording(recording)
                connectivityManager.sendRecording(recording: recording)
                
                recordingManager.monitorUpdates(recording: recording, handleUpdate: { sensorData in
                    self.dataSource.appendSensorData(sensorData)
                    self.connectivityManager.sendSensorData(sensorData: sensorData)
                })
                
            } catch {
                print("Error starting recording", error)
            }

        }
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
        started = false
    }

    func toggle() {
        toggleTimer()

        if recordingManager.isRecording {
            stop()
            sync()
            return
        }

        start()
    }

    func getCountOfUnsyncedData() -> Int? {
        if recordingManager.isRecording {
            print("Cannot get count of unsynced data while recording")
            return nil
        }
        return getCountOfUnsyncedSensorData()! + getCountOfUnsyncedRecordingData()!
    }

    func getCountOfUnsyncedSensorData() -> Int? {
        if recordingManager.isRecording {
            print("Cannot get count of unsynced sensor data while recording")
            return nil
        }
        return dataSource.fetchSensorDataArray().count
    }

    func getCountOfUnsyncedRecordingData() -> Int? {
        if recordingManager.isRecording {
            print("Cannot get count of unsynced recording data while recording")
            return nil
        }
        return dataSource.fetchRecordingArray().count
    }
}
