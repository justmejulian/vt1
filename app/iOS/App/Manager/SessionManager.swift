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

class SessionManager: NSObject, ObservableObject {
    static let shared = SessionManager()

    @ObservedObject
    private var connectivityManager = ConnectivityManager.shared

    @ObservationIgnored
    private let workoutManager = WorkoutManager.shared

    @Published var isSessionRunning: Bool? = nil

    func refreshSessionState() {
        connectivityManager.getSessionState()
    }

    func toggle(text: String?) async {
        guard isSessionRunning != nil else {
            return
        }
        
        if isSessionRunning! {
            await stop()
        } else {
            await start(text: text)
        }
    }

    private func start(text: String?) async {
        do {
            isSessionRunning = true
            try await workoutManager.startWatchWorkout()
            connectivityManager.sendStartSession(exerciseName: text ?? "")
        } catch {
            print(error)
        }
    }

    private func stop() async {
        
        // what happens when the watch is sleeping
        isSessionRunning = false
        connectivityManager.sendStopSession()
    }
}
