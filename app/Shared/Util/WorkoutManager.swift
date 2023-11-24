//
//  WorkoutManager.swift
//  vt1
//
//  Created by Julian Visser on 21.11.2023.
//

import Foundation
import CoreMotion
import HealthKit

@MainActor
class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()

    let healthStore = HKHealthStore()
    
    var session: HKWorkoutSession?

    #if os(watchOS)
    var builder: HKLiveWorkoutBuilder?
    #endif

    var started: Bool = false

    func resetWorkout() {
        session = nil
        #if os(watchOS)
        builder = nil
        #endif
        started = false
    }

}

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
}
