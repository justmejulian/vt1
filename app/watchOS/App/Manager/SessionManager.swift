//
//  SessionManager.swift
//  vt1
//
//  Created by Julian Visser on 24.11.2023.
//

import Foundation
import HealthKit
import OSLog

class SessionManager: NSObject, ObservableObject {
    static let shared = SessionManager()
    
    let recordingManager = RecordingManager()
    
    // do these all need to be shared?
    let workoutManager = WorkoutManager.shared
    
    let modelContainer = DataSource.shared.getModelContainer()
    
    private let dataSource = DataSource.shared
    
    private let connectivityManager = ConnectivityManager.shared
    
    @Published var timeCounter = 0

    var timer: Timer? = nil
    
    @Published var loading = false
    @Published var started = false
    @Published var exerciseName: String? = nil
    @Published var sensorDataCount: Int = 0
    
    func startWorkout() async {
        Logger.viewCycle.info("Crating Workout to start Session")
        do {
            try await workoutManager.startWorkout()
        } catch {
            Logger.viewCycle.error("Error starting workout from session \(error)")
        }
    }

    @MainActor
    func start(exerciseName: String = "Default") async {
        Logger.viewCycle.info("Called start SessionManager")
        loading = true
        
        await requestAuthorization()
        
        if (!workoutManager.started) {
            await startWorkout()
        }
        
        self.exerciseName = exerciseName
        
        Logger.viewCycle.info("Starting Session for exerciseName \(exerciseName)")
        
        started = true
        sensorDataCount = 0
        
        sendSessionState(isSessionRunning: true)
        
        do {
            Logger.viewCycle.info("Starting Recording")
            // Start Recording
            let recording = try recordingManager.start(exercise: exerciseName)
            
            // Store Recording
            dataSource.appendRecording(recording)
            
            // Send Recording
            sendRecording(recording: recording)
            
            Task {
                do {
                    Logger.viewCycle.info("Starting monitororig Updates")
                    try await recordingManager.monitorUpdates(recording: recording, handleUpdate: { sensorData in
                        DispatchQueue.main.async {
                            self.sensorDataCount += sensorData.values.count
                        }
                        
                        // Start Timer after first monitorUpdate is recieved
                        if (self.loading){
                            DispatchQueue.main.async {
                                Logger.viewCycle.debug("First monitorUpdate revieved. Starting Timer.")
                                self.startTimer()
                                self.loading = false
                            }
                        }
                        // Store Sensor Data
                        self.dataSource.appendSensorData(sensorData)
                        // Send Sensor Data
                        self.sendSensorData(sensorData: sensorData)
                    })
                } catch {
                    Logger.viewCycle.error("Error starting monitorUpdates: \(error)")
                    self.stop()
                }
            }
            
        } catch {
            Logger.viewCycle.error("Error starting session: \(error)")
            stop()
        }
    }
    
    func sendSensorData(sensorData: SensorData) {
        // Logger.viewCycle.debug("Calling SessionManager sendSensorData for \(sensorData.timestamp)")
        self.connectivityManager.sendSensorData(sensorData: sensorData, replyHandler:  { (replyData: [String: Any]) in
            if replyData["sucess"] != nil {
                // Logger.viewCycle.debug("Sucsessfuly sent sensorData timestamp \(sensorData.timestamp)")
                
                // Remove synced Sensor Data
                self.dataSource.removeData(sensorData)
                // Logger.viewCycle.debug("Removed sensorData timestamp \(sensorData.timestamp) from store")
                
                return
            }
            
            Logger.viewCycle.error("Something went wrong sending sensor data")
            
            if let error = replyData["error"] {
                if let errorString = error as? String {
                    
                    Logger.viewCycle.error("Reply Error: \(errorString)")

                    return
                }
                
                Logger.viewCycle.error("Reply Error that was not a string.")
                
                return
            }
        })
    }
    
    func sendSessionState(isSessionRunning: Bool){
        Logger.viewCycle.debug("Calling SessionManager sendSessionState isSessionRunning \(isSessionRunning)")
        connectivityManager.sendSessionState(isSessionRunning: isSessionRunning)
    }
    
    func sendRecording(recording: RecordingData) {
        // Logger.viewCycle.debug("Calling SessionManager sendRecording for \(recording.startTimestamp)")
        self.connectivityManager.sendRecording(recording: recording, replyHandler:  { replyData in
            if replyData["sucess"] != nil {
                // Logger.viewCycle.debug("Sucsessfuly sent recording timestamp \(recording.startTimestamp)")
                // Remove synced Sensor Data
                self.dataSource.removeData(recording)
                
                // Logger.viewCycle.debug("Removed recording timestamp \(recording.startTimestamp) from store")
                return
            }

            Logger.viewCycle.error("Something went wrong sending recording data")

            if let error = replyData["error"] {
                if let errorString = error as? String {
                    
                    Logger.viewCycle.error("Reply Error: \(errorString)")

                    return
                }
                
                Logger.viewCycle.error("Reply Error that was not a string.")
                
                return
            }
        })
    }

    func sync() {
        Logger.viewCycle.debug("Starting SessionManager sync")
        let sensorData = dataSource.fetchSensorDataArray()
        let recordings = dataSource.fetchRecordingArray()

        Logger.statistics.info("Syncing \(sensorData.count) SensorData and \(recordings.count) Recordings")
        sensorData.forEach { sensorData in
            sendSensorData(sensorData: sensorData)
        }
        recordings.forEach { recording in
            sendRecording(recording: recording)
        }
        Logger.viewCycle.debug("Finished Syncing")
    }

    func stop() {
        loading = true
        Logger.viewCycle.debug("Stopping SessionManager session")
        DispatchQueue.main.async {
            self.stopTimer()
        }
        started = false
        recordingManager.stop()
        
        sendSessionState(isSessionRunning: false)
        Task {
            await workoutManager.resetWorkout()
            DispatchQueue.main.async {
                self.loading = false
            }
        }
    }

    func toggle() {
        Logger.viewCycle.debug("SessionManager toggle called")
        if started {
            Logger.viewCycle.debug("SessionManager session was started, stopping")
            stop()
            sync()
            return
        }

        Task{
            Logger.viewCycle.debug("SessionManager session was stopped, starting")
            await start()
        }
    }
    
    // Timer needs to run on main to make sure it updated correctly
    @MainActor private func startTimer() {
        Logger.viewCycle.debug("Starting Timer")
        if timer != nil {
            Logger.viewCycle.warning("Timer already running")
        }
        timeCounter = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Update the counter every second
            self.timeCounter += 1
        }
    }
    
    @MainActor private func stopTimer() {
        Logger.viewCycle.debug("Stopping Timer")
        if timer == nil {
            Logger.viewCycle.warning("No Timer running")
        }
        timer?.invalidate()
        timer = nil
    }

    func getCountOfUnsyncedData() -> Int? {
        Logger.viewCycle.debug("Called getCountOfUnsyncedData")
        if recordingManager.isRecording {
            Logger.viewCycle.debug("Cannot get count of unsynced data while recording")
            return nil
        }
        return getCountOfUnsyncedSensorData()! + getCountOfUnsyncedRecordingData()!
    }

    func getCountOfUnsyncedSensorData() -> Int? {
        Logger.viewCycle.debug("Called getCountOfUnsyncedSensorData")
        if recordingManager.isRecording {
            Logger.viewCycle.error("Cannot get count of unsynced sensor data while recording")
            return nil
        }
        return dataSource.fetchSensorDataArray().count
    }

    func getCountOfUnsyncedRecordingData() -> Int? {
        if recordingManager.isRecording {
            Logger.viewCycle.error("Cannot get count of unsynced recording data while recording")
            return nil
        }
        return dataSource.fetchRecordingArray().count
    }

    func requestAuthorization() async {
        Logger.viewCycle.debug("Requestion requestAuthorization in SessionManager")
        await workoutManager.requestAuthorization()
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
