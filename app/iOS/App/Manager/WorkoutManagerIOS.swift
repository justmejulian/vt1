//
//  Created by Julian Visser on 21.11.2023.
//

import Foundation
import CoreMotion
import HealthKit
import OSLog

extension WorkoutManager {
    func startWatchWorkout() async throws {

        Logger.viewCycle.info("Running start Watch Workout from WorkoutManager")

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .functionalStrengthTraining
        configuration.locationType = .indoor

        do {
            try await healthStore.startWatchApp(toHandle: configuration)
            Logger.viewCycle.debug("Started WatchApp from WorkoutManager")
        } catch {
            Logger.viewCycle.error("Failed to startWatchApp from WorkoutManager: \(error.localizedDescription)")
        }
    }
}
