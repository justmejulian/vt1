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

class SessionManager: NSObject, ObservableObject {
    @ObservedObject
    private var connectivityManager: ConnectivityManager

    @ObservationIgnored
    private let workoutManager: WorkoutManager
    
    @ObservationIgnored
    private let dataSource: DataSource

    @Published
    var isSessionRunning: Bool = false

    @Published
    var isLoading: Bool? = nil
    
    var exerciseName: String? = nil
    
    init(workoutManager: WorkoutManager, connectivityManager: ConnectivityManager, dataSource: DataSource) {
        
        self.connectivityManager = connectivityManager
        self.workoutManager = workoutManager
        self.dataSource = dataSource
        
        super.init()

        addListeners()
    }

    func refreshSessionState() {
        Logger.viewCycle.debug("refreshSessionState from SessionManager")
        connectivityManager.getSessionState()
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
        
        do {
            try await workoutManager.startWatchWorkout()
            
            exerciseName = text
            
            Logger.viewCycle.debug("started watchWorkout from SessionManager at \(Date())")
        } catch {
            Logger.viewCycle.error("\(error.localizedDescription)")
        }
    }
    
    // Called when watch tell iphone that it is ready
    public func startSession() async {
        Logger.viewCycle.debug("startSession from SessionManager at \(Date())")
        
        isSessionRunning = true
        connectivityManager.sendStartSession(exerciseName: exerciseName ?? "")
        
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
    
    private func addListeners() {
        // todo maybe create a LinsterMangager or SessionConnectity
        let recordingListener = Listener(key: "recording", handleData: { data in
            if let endcodedRecording = data["recording"] {
                guard let recording = try? JSONDecoder().decode(RecordingData.self, from: endcodedRecording as! Data) else {
                    throw SessionError("Could not decode recording")
                }
                
                self.dataSource.appendRecording(recording)
                return
            }
        })
        connectivityManager.addListener(recordingListener)

        let sensorDataListener = Listener(key: "sensorData", handleData: { data in
            if let endcodedSensorData = data["sensorData"] {
                guard let sensorData = try? JSONDecoder().decode(SensorData.self, from: endcodedSensorData as! Data) else {
                    throw SessionError("Could not decode sensorData")
                }

                self.dataSource.appendSensorData(sensorData)
                return
            }
        })
        connectivityManager.addListener(sensorDataListener)

        let isSessionRunningListener = Listener(key: "isSessionRunning", handleData: { data in
            if let isSessionRunning = data["isSessionRunning"] {
                guard let isSessionRunningBool = isSessionRunning as? Bool else {
                    throw SessionError("Could not decode isSessionRunning")
                }

                Logger.viewCycle.debug("recived isSessionRunning: \(isSessionRunningBool)")

                DispatchQueue.main.async {

                    self.isSessionRunning = isSessionRunningBool
                }
                return
            }
        })
        connectivityManager.addListener(isSessionRunningListener)

        let isSessionReadyListener = Listener(key: "isSessionReady", handleData: { data in
            if let isSessionReady = data["isSessionReady"] {
                guard let isSessionReadyBool = data["isSessionReady"] as? Bool else {
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
