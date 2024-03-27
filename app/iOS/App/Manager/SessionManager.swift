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
    static let shared = SessionManager()

    @ObservedObject
    private var connectivityManager = ConnectivityManager.shared

    @ObservationIgnored
    private let workoutManager = WorkoutManager.shared

    @Published var isSessionRunning: Bool? = nil
    
    var exerciseName: String? = nil

    func refreshSessionState() {
        Logger.viewCycle.debug("refreshSessionState from SessionManager")
        connectivityManager.getSessionState()
    }

    func toggle(text: String?) async {
        Logger.viewCycle.debug("toggle from SessionManager")
        guard isSessionRunning != nil else {
            Logger.viewCycle.debug("isSessionRunning was null")
            return
        }
        
        if isSessionRunning! {
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
        
        Logger.viewCycle.debug("started watchWorkout and session from SessionManager at \(Date())")

    }

    private func stop() async {
        Logger.viewCycle.debug("stop from SessionManager")

        // what happens when the watch is sleeping
        isSessionRunning = false
        connectivityManager.sendStopSession()
    }
}
