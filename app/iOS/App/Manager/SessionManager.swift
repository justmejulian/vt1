//
//  SessionManager.swift
//  vt1 Mobile App
//
//  Created by Julian Visser on 29.11.2023.
//

import Foundation
import SwiftUI
import SwiftData
import HealthKit
import OSLog

@MainActor
class SessionManager: NSObject, ObservableObject {
    private var connectivityManager: ConnectivityManager
    
    @ObservationIgnored
    private let workoutManager: WorkoutManager
    
    private let db: Database
    
    @Published
    var isSessionRunning: Bool = false
    
    @Published
    var isLoading: Bool? = nil
    
    @Published
    var hasError: Bool = false
    @Published
    var errorMessage: String = ""
    @Published
    var recording: RecordingStruct? = nil
    @Published
    var sensorValueCount = 0
    
    var exerciseName: String? = nil
    
    init(workoutManager: WorkoutManager, connectivityManager: ConnectivityManager, db: Database) {
        
        self.connectivityManager = connectivityManager
        self.workoutManager = workoutManager
        self.db = db
        
        super.init()
        
        addListeners()
    }
    
    func refreshSessionState() {
        Logger.viewCycle.debug("refreshSessionState from SessionManager")
        self.reset()
        // needed? not handled by is session running?
        connectivityManager.getSessionState()
        // todo maybe throw and catch?
    }
    
    func toggle(text: String?) async {
        isLoading = true
        Logger.viewCycle.debug("toggle from SessionManager")
        
        if isSessionRunning {
            Logger.viewCycle.debug("isSessionRunning was true, stopping")
            await stop()
        } else {
            Logger.viewCycle.debug("isSessionRunning was false, starting")
            await start(text: text)
        }
        Logger.viewCycle.debug("Finished toggle from SessionManager")
    }
    
    private func start(text: String?) async {
        Logger.viewCycle.debug("start from SessionManager at \(Date())")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            Logger.viewCycle.debug("SessionManager timer fired: \(String(self.isLoading ?? false))")
            if let isLoading = self.isLoading {
                if (isLoading ) {
                    Logger.viewCycle.debug("SessionManager timed out! Stopping Session.")
                    
                    Task{
                        self.handleError(message: "SessionManager timed out! Stopping Session.")
                        await self.stop()
                    }
                }
            }
        }
        
        await workoutManager.startWatchWorkout()
        
        exerciseName = text
        
        Logger.viewCycle.debug("started watchWorkout from SessionManager at \(Date())")
    }
    
    // Called when watch tell iphone that it is ready
    public func startSession() async {
        Logger.viewCycle.debug("startSession from SessionManager at \(Date())")
        
        isSessionRunning = true
        connectivityManager.sendStartSession(exerciseName: exerciseName ?? "", errorHandler: {
            error in
            Task {
                self.handleError(message: "Cound not start Session: \(error.localizedDescription)")
                await self.stop()
            }
        })
        
        isLoading = false
        
        Logger.viewCycle.debug("started watchWorkout and session from SessionManager at \(Date())")
    }
    
    private func stop() async {
        Logger.viewCycle.debug("stop from SessionManager")
        
        // todo what happens when the watch is sleeping
        isSessionRunning = false
        isLoading = false
        connectivityManager.sendStopSession()
    }
    
    private func updateSensorValuesCount(_ increase: Int) {
        self.sensorValueCount += increase
    }
    
    private func setCurrentRecording(_ recording: RecordingStruct) {
        self.recording = recording
    }
    
    private func addListeners() {
        // todo maybe create a LinsterMangager or SessionConnectity
        let recordingListener = Listener(key: "recording", handleData: { data in
            if let endcodedRecording = data["recording"] as? Data {
                Task.detached(priority: .background) {
                    guard let recording = try? JSONDecoder().decode(RecordingStruct.self, from: endcodedRecording) else {
                        throw SessionError("Could not decode recording")
                    }
                    
                    let recordingBackgroundDataHandler = await RecordingBackgroundDataHandler(modelContainer: self.db.getModelContainer())
                    let _ = await recordingBackgroundDataHandler.appendData(recording)
                    await self.setCurrentRecording(recording)
                }
                return
            }
        })
        connectivityManager.addListener(recordingListener)
        
        let sensorBatchListener = Listener(key: "sensorBatch", handleData: { data in
            Logger.viewCycle.debug("Listener handler sensorBatch called on Thread \(Thread.current) is MainThread \(Thread.isMainThread)")
            if let endcodedSensorBatch = data["sensorBatch"] as? Data {
                // todo don't decode, just compress
                // todo keep count of recieved data count
                Task.detached(priority: .background) {
                    Logger.viewCycle.debug("Creating SensorBatch from Json on Thread \(Thread.current) is MainThread \(Thread.isMainThread)")
                    
                    guard let sensorBatchStruct = try? JSONDecoder().decode(SensorBatchStruct.self, from: endcodedSensorBatch) else {
                        throw SessionError("Could not decode sensorBatch")
                    }
                    
                    let sensorBatchBackgroundDataHandler = await SensorBatchBackgroundDataHandler(modelContainer: self.db.getModelContainer())
                    let _ = await sensorBatchBackgroundDataHandler.appendData(sensorBatchStruct)
                    // todo move to SensorBatchDataHandler
                    await self.updateSensorValuesCount(sensorBatchStruct.values.count)
                }
                return
            }
        })
        self.connectivityManager.addListener(sensorBatchListener)
        
        let isSessionRunningListener = Listener(key: "isSessionRunning", handleData: { data in
            if let isSessionRunning = data["isSessionRunning"] {
                Task {
                    guard let isSessionRunningBool = isSessionRunning as? Bool else {
                        throw SessionError("Could not decode isSessionRunning")
                    }
                    
                    Logger.viewCycle.debug("recived isSessionRunning: \(isSessionRunningBool)")
                    
                    if (!(await self.isSessionRunning) && isSessionRunningBool) {
                        await self.reset()
                    }
                    
                    await self.setIsSessionRunning(to: isSessionRunningBool)
                    return
                }
            }
        })
        connectivityManager.addListener(isSessionRunningListener)
        
        let isSessionReadyListener = Listener(key: "isSessionReady", handleData: { data in
            if let isSessionReady = data["isSessionReady"] {
                guard let isSessionReadyBool = isSessionReady as? Bool else {
                    throw SessionError("Could not decode isSessionReady")
                }
                
                Logger.viewCycle.debug("recived isSessionReady: \(isSessionReadyBool)")
                
                Task {
                    await self.startSession()
                }
                return
            }
        })
        connectivityManager.addListener(isSessionReadyListener)
    }
    
    func setIsSessionRunning(to bool: Bool) {
        self.isSessionRunning = bool
    }
    
    func handleError(message: String){
        self.errorMessage = message
        self.hasError = true
        self.isLoading = false
    }
    
    func reset(){
        self.errorMessage = ""
        self.sensorValueCount = 0
        self.hasError = false
        self.isLoading = false
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
