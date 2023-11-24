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
        configuration.locationType = .outdoor
        healthStore.startWatchApp(with: configuration, completion: { success, error in
            if let error = error {
                print("Error starting watch app: \(error.localizedDescription)")
            }
            if success {
                print("success")
                // todo if successful send start recording
            }
        })
    }
}
