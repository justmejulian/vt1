//
//  SessionManager.swift
//  vt1
//
//  Created by Julian Visser on 24.11.2023.
//

import Foundation
import HealthKit

class SessionManager: NSObject, ObservableObject {

    static let shared = SessionManager()
    
    let recordingManager = RecordingManager()
    
    let workoutManager = WorkoutManager.shared
    
    let modelContainer = DataSource.shared.getModelContainer()
    
    private let dataSource = DataSource.shared
    
    private let connectivityManager = ConnectivityManager.shared
    
    @Published var timeCounter = 0

    var timer: Timer? = nil
    
    @Published var started = false
    @Published var exerciseName: String? = nil
    @Published var sensorDataCount: Int = 0
    
    func startWorkout() async {
        print("Crating Workout to start Session")
        do {
            try await workoutManager.startWorkout()
        } catch {
            print("Error starting workout from session", error)
        }
    }

    @MainActor
    func start(exerciseName: String = "Default") async {
        if (!workoutManager.started) {
            await startWorkout()
        }
        
        self.exerciseName = exerciseName
        
        print("Start Session")
        
        started = true
        
        startTimer()
        
        do {
            // Start Recording
            let recording = try recordingManager.start()
            
            // Store Recording
            dataSource.appendRecording(recording)
            
            // Send Recording
            sendRecording(recording: recording)
            
            recordingManager.monitorUpdates(recording: recording, handleUpdate: { sensorData in
                
                self.sensorDataCount += sensorData.values.count
                // Store Sensor Data
                self.dataSource.appendSensorData(sensorData)
                // Send Sensor Data
                self.sendSensorData(sensorData: sensorData)
            })
            
        } catch {
            print("Error starting session", error)
        }
    }
    
    func sendSensorData(sensorData: SensorData) {
        self.connectivityManager.sendSensorData(sensorData: sensorData, replyHandler:  { replyData in
            if replyData["sucess"] != nil {
                
                // Remove synced Sensor Data
                self.dataSource.removeData(sensorData)
                return
            }
            print("Something went wrong sending data")
            if let error = replyData["error"] {
                print(error)
                return
            }
        })
    }
    
    func sendRecording(recording: RecordingData) {
        self.connectivityManager.sendRecording(recording: recording, replyHandler:  { replyData in
            if replyData["sucess"] != nil {
                // Remove synced Sensor Data
                self.dataSource.removeData(recording)
                return
            }
            print("Something went wrong sending data")
            if let error = replyData["error"] {
                print(error)
                return
            }
        })
    }

    func sync() {
        print("Start Syncing")
        let sensorData = dataSource.fetchSensorDataArray()
        let recordings = dataSource.fetchRecordingArray()

        print("Syncing \(sensorData.count) SensorData and \(recordings.count) Recordings")
        sensorData.forEach { sensorData in
            sendSensorData(sensorData: sensorData)
        }
        recordings.forEach { recording in
            sendRecording(recording: recording)
        }
        print("Finished Syncing")
    }

    private func stop() {
        stopTimer()
        started = false
        recordingManager.stop()
        Task {
            await workoutManager.resetWorkout()
        }
    }

    func toggle() {
        if started {
            stop()
            sync()
            return
        }

        Task{
            await start()
        }
    }
    
    private func startTimer() {
        if timer != nil {
            print("Timer already running")
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Update the counter every second
            self.timeCounter += 1
        }
    }
    
    private func stopTimer() {
        if timer == nil {
            print("No Timer running")
        }
        timer?.invalidate()
        timer = nil
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

    func requestAuthorization(){
        Task{
            await workoutManager.requestAuthorization()
        }
    }
}

struct SessionError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}
