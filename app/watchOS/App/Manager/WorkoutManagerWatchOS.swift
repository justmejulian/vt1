//
//  Created by Julian Visser on 21.11.2023.
//

import Foundation
import CoreMotion
import HealthKit
import OSLog

extension WorkoutManager {
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        Logger.viewCycle.info("requestAuthorization from WorkoutManager")
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            
            // todo we need to wait for this
            if success {
                Logger.viewCycle.info("successfuly requested Authorization from WorkoutManager")
                return
            }

            if let error = error {
                Logger.viewCycle.error("requestAuthorization error: \(error.localizedDescription)")
                return
            }
        }

    }

    func startWorkout() async throws {
        Logger.viewCycle.info("startWorkout from WorkoutManager")


        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .functionalStrengthTraining
        configuration.locationType = .outdoor

        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()

        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        let startDate = Date()

        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)

        started = true
        Logger.viewCycle.debug("started workout from WorkoutManager \(startDate)")
    }

    func handleReceivedData(_ data: Data) throws {
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        Logger.viewCycle.debug("workoutBuilderDidCollectEvent in WorkoutManager")
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
    }
}
