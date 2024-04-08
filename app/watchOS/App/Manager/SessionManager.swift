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
    private let recordingManager = RecordingManager()

    // do these all need to be shared?
    private let workoutManager: WorkoutManager

    private let dataSource: DataSource

    private let connectivityManager: ConnectivityManager

    @Published var timeCounter = 0

    var timer: Timer? = nil

    @Published var loading = false
    @Published var started = false
    @Published var exerciseName: String? = nil
    @Published var sensorDataCount: Int = 0

    // todo why override?
    init(workoutManager: WorkoutManager, dataSource: DataSource, connectivityManager: ConnectivityManager) {

        self.workoutManager = workoutManager
        self.dataSource = dataSource
        self.connectivityManager = connectivityManager

        super.init()

        self.addListeners()
    }
    
    func startWorkout() async {
        Logger.viewCycle.info("Crating Workout to start Session")
        do {
            try await workoutManager.startWorkout()
        } catch {
            Logger.viewCycle.error("Error starting workout from session \(error)")
        }
    }

    func start(exerciseName: String = "Default") async {
        Logger.viewCycle.info("Called start SessionManager")
        DispatchQueue.main.async {
            self.loading = true
        }
        
        await requestAuthorization()

        if (!workoutManager.started) {
            await startWorkout()
        }
        
        DispatchQueue.main.async {
            self.exerciseName = exerciseName
            self.started = true
            self.sensorDataCount = 0
        }
        
        Logger.viewCycle.info("Starting Session for exerciseName \(exerciseName)")

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
                                if (self.loading){
                                    Logger.viewCycle.debug("First monitorUpdate revieved. Starting Timer.")
                                    self.loading = false
                                    self.startTimer()
                                }
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

        workoutManager.resetWorkout()
        self.loading = false
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
            await self.start()
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
    
    // Timer needs to run on main to make sure it updated correctly
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
    
    private func addListeners() {
        let startSessionListener = Listener(key: "startSession", handleData: { data in
            if let exerciseName = data["startSession"] {
                Logger.viewCycle.info("recived start session")
                
                guard let exerciseName = exerciseName as? String else {
                    throw SessionError("Could not decode exerciseName")
                }
                
                    Logger.viewCycle.info("start session with exerciseName: \(exerciseName)")

                    Task {
                        await self.start(exerciseName: exerciseName)
                    }
                    return
            }
        })

        connectivityManager.addListener(startSessionListener)

        let stopSessionListener = Listener(key: "stopSession", handleData: { data in
            if data["stopSession"] != nil {
                Logger.viewCycle.info("recived stop session")
                self.stop()
                return
            }
        })

        connectivityManager.addListener(stopSessionListener)

        let getSessionStateListener = Listener(key: "getSessionState", handleData: { data in
            if data["getSessionState"] != nil {
                Logger.viewCycle.info("recived getSessionState")
                
                // send session state
                self.connectivityManager.sendSessionState(isSessionRunning: self.started)
                
                return
            }
        })

        connectivityManager.addListener(getSessionStateListener)
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
