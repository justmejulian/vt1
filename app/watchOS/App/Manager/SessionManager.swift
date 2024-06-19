//
//  SessionManager.swift
//  vt1
//
//  Created by Julian Visser on 24.11.2023.
//

import Foundation
import HealthKit
import WatchKit
import OSLog
import SwiftData

@MainActor
class SessionManager: NSObject, ObservableObject {
    
    let workoutManager = WorkoutManager.shared
    let connectivityManager = ConnectivityManager.shared
    
    private let recordingManager = RecordingManager()
    
    private let db: Database
    
    let timeManager = TimerManager()
    
    @Published var loadingMap = [
        "acceleration": false,
        "rotationRate": false,
        "userAcceleration": false,
        "gravity": false,
        "quaternion": false,
    ]
    
    @Published var started = false
    @Published var exerciseName: String? = nil
    @Published var sensorDataCount: Int = 0
    
    // todo why override?
    init(db: Database) {
        self.db = db
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            print("SessionManager timer fired: ", self.loadingMap)
            if (self.loadingMap.contains(where: { $0.value == true})) {
                print("SessionManager timed out! Stopping Session.")
                WKInterfaceDevice.current().play(.failure)
                self.stop()
            }
        }
        
        WKInterfaceDevice.current().play(.start)
        
        let newLoading = self.loadingMap.mapValues { value in
            return true
        }
        self.loadingMap = newLoading
        
        await requestAuthorization()
        
        if (!workoutManager.started) {
            await startWorkout()
        }
        
        self.exerciseName = exerciseName
        self.started = true
        self.sensorDataCount = 0
        
        Logger.viewCycle.info("Starting Session for exerciseName \(exerciseName)")
        
        sendSessionState(isSessionRunning: true)
        
        do {
            Logger.viewCycle.info("Starting Recording")
            // Start Recording
            let recording = try recordingManager.start(exercise: exerciseName)
            
            // Store Recording
            let dataHandler = BackgroundDataHandler(modelContainer: self.db.getModelContainer())
            await dataHandler.appendData(recording)
            
            // Send Recording
            sendRecording(recording: recording)
            
            do {
                Logger.viewCycle.info("Starting monitororig Updates")
                try await recordingManager.monitorUpdates(recording: recording, handleUpdate: {
                    recordingStart, timestamp, sensor_id, values in
                    Task {
                        await self.increaseSensorBatchCount(by: values.count)
                        
                        // Start Timer after first monitorUpdate is recieved
                        let isSensorLoading = await self.isSensorLoading(sensor_id)
                        if isSensorLoading {
                            DispatchQueue.main.async {
                                Logger.viewCycle.debug("\(sensor_id) monitorUpdate revieved.")
                                self.loadingMap[sensor_id] = false
                                
                                if (!self.loadingMap.contains(where: {$0.value == true})){
                                    Logger.viewCycle.debug("All first monitorUpdates revieved. Starting Timer.")
                                    WKInterfaceDevice.current().play(.success)
                                    self.timeManager.start()
                                }
                                
                            }
                        }
                        let sensorData = SensorBatch(recordingStart: recordingStart, timestamp: timestamp, sensor_id: sensor_id, values: values)
                        // Store Sensor Data
                        let dataHandler = await BackgroundDataHandler(modelContainer: self.db.getModelContainer())
                        await dataHandler.appendData(sensorData)
                        //                        let sensorBackgroundDataHandler = SensorBatchHandler(dataHandler: dataHandler)
                        //                        await sensorBackgroundDataHandler.createSensorBatch(recordingStart: recordingStart, timestamp: timestamp, sensor_id: sensor_id, values: values)
                        
                        // Send Sensor Data
                        await self.sendSensorBatch(sensorData: sensorData)
                    }
                })
            } catch {
                Logger.viewCycle.error("Error starting monitorUpdates: \(error)")
                self.stop()
            }
            
        } catch {
            Logger.viewCycle.error("Error starting session: \(error)")
            stop()
        }
    }
    
    func isSensorLoading(_ id: String) -> Bool {
        guard let isCurrentLoading = self.loadingMap[id] else {
            Logger.viewCycle.debug("Could not find sensor in loading Map \(id)")
            return false
        }
        
        return isCurrentLoading
    }
    
    func increaseSensorBatchCount(by count: Int){
        self.sensorDataCount += count
    }
    
    func sendSensorBatch(sensorData: SensorBatch) {
        // Logger.viewCycle.debug("Calling SessionManager sendSensorBatch for \(sensorData.timestamp)")
        self.connectivityManager.sendSensorBatch(sensorData: sensorData, replyHandler:  { (replyData: [String: Any]) in
            if replyData["sucess"] != nil {
                // Logger.viewCycle.debug("Sucsessfuly sent sensorData timestamp \(sensorData.timestamp)")
                
                // Remove synced Sensor Data
                Task {
                    let dataHandler = BackgroundDataHandler(modelContainer: self.db.getModelContainer())
                    await dataHandler.removeData(sensorData)
                    Logger.viewCycle.debug("Removed sensorData timestamp \(sensorData.timestamp) from store")
                }
                
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
    
    func sendRecording(recording: Recording) {
        // Logger.viewCycle.debug("Calling SessionManager sendRecording for \(recording.startTimestamp)")
        self.connectivityManager.sendRecording(recording: recording, replyHandler:  { replyData in
            if replyData["sucess"] != nil {
                // Logger.viewCycle.debug("Sucsessfuly sent recording timestamp \(recording.startTimestamp)")
                // Remove synced Sensor Data
                Task {
                    let dataHandler = await BackgroundDataHandler(modelContainer: self.db.getModelContainer())
                    await dataHandler.removeData(recording)
                }
                
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
        // todo need to be done in the background
        Logger.viewCycle.debug("Starting SessionManager sync")
        Task.detached {
            do {
                let sensorData: [SensorBatch] = await self.db.fetchData()
                let recordings: [Recording] = await self.db.fetchData()
                
                Logger.statistics.info("Syncing \(sensorData.count) SensorBatch and \(recordings.count) Recordings")
                sensorData.forEach { sensorData in
                    Task {
                        await self.sendSensorBatch(sensorData: sensorData)
                    }
                }
                recordings.forEach { recording in
                    Task {
                        await self.sendRecording(recording: recording)
                    }
                }
                Logger.viewCycle.debug("Finished Syncing")
            } catch {
                Logger.viewCycle.debug("Failed during SessionManager sync: \(error.localizedDescription)")
            }
        }
    }
    
    func stop() {
        Logger.viewCycle.debug("Stopping SessionManager session")
        
        WKInterfaceDevice.current().play(.stop)
        
        DispatchQueue.main.async {
            self.started = false
            self.timeManager.stop()
            let newLoading = self.loadingMap.mapValues { value in
                return false
            }
            self.loadingMap = newLoading
        }
        
        recordingManager.stop()
        
        sendSessionState(isSessionRunning: false)
        
        workoutManager.resetWorkout()
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
