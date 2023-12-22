//
//  Created by Julian Visser on 21.11.2023.
//

import os
import WatchKit
import HealthKit
import SwiftUI

class AppDelegate: NSObject, WKApplicationDelegate {
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        print("AppDelegate: handle")
        Task {
            do {
                WorkoutManager.shared.resetWorkout()
                try await WorkoutManager.shared.startWorkout()
                print("Successfully started workout")
            } catch {
                print("Failed started workout")
            }
        }
    }
}
