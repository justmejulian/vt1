//
//  Created by Julian Visser on 21.11.2023.
//

import Foundation
import CoreMotion
import HealthKit

extension WorkoutManager {
    func startWatchWorkout() async throws {
        print("Running start Watch Workout")
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .functionalStrengthTraining
        configuration.locationType = .indoor
        try await healthStore.startWatchApp(toHandle: configuration)
    }
}
