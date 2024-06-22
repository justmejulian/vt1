//
//  Created by Julian Visser on 21.11.2023.
//

import Foundation
import CoreMotion
import HealthKit
import OSLog

extension WorkoutManager {
    // Request authorization to access HealthKit.
    func requestAuthorization() async {
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
        
        do {
            // Check that Health data is available on the device.
            if HKHealthStore.isHealthDataAvailable() {
                
                // Asynchronously request authorization to the data.
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
                Logger.viewCycle.info("successfuly requested Authorization from WorkoutManager")
            }
        } catch {
            
            // Typically, authorization requests only fail if you haven't set the
            // usage and share descriptions in your app's Info.plist, or if
            // Health data isn't available on the current device.
            fatalError("*** An unexpected error occurred while requesting authorization: \(error.localizedDescription) ***")
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

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        Logger.viewCycle.debug("workoutBuilderDidCollectEvent in WorkoutManager")
    }

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
    }
}
