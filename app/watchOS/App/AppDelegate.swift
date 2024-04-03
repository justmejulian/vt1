//
//  Created by Julian Visser on 21.11.2023.
//

import os
import WatchKit
import HealthKit
import SwiftUI

class AppDelegate: NSObject, WKApplicationDelegate {
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        Logger.viewCycle.info("AppDelegate: handle")
        Task {
            do {
                Logger.viewCycle.debug("calling resetWorkout from AppDelegate")
                WorkoutManager.shared.resetWorkout()
                Logger.viewCycle.debug("calling startWorkout from AppDelegate")
                try await WorkoutManager.shared.startWorkout()
                
                // todo send info to iphone to start session
                ConnectivityManager.shared.sendSessionReadyToStart()
            } catch {
                Logger.viewCycle.error("Failed stating workout from AppDelegate")
            }
        }
    }
}
