//
//  vt1
//
//  Created by Julian Visser on 21.11.2023.
//

import Foundation
import CoreMotion
import HealthKit
import OSLog

class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    
    var session: HKWorkoutSession?

    #if os(watchOS)
    var builder: HKLiveWorkoutBuilder?
    #endif

    var started: Bool = false

    func resetWorkout() {
        Logger.viewCycle.info("resetWorkout WorkoutManager")
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
