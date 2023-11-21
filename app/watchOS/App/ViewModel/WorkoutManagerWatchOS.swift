//
//  Created by Julian Visser on 21.11.2023.
//

import Foundation
import CoreMotion
import HealthKit

extension WorkoutManager {
    // Request authorization to access HealthKit.
    func requestAuthorization() {
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
            // Handle error.
            if error != nil {
                print(error!)
                return
            }
        }
    }

    func startWorkout() async throws {
        print("start workout")
        guard CMBatchedSensorManager.isAccelerometerSupported && CMBatchedSensorManager.isDeviceMotionSupported else {
            print("Error CMBatchedSensorManager not supported, check permissions")
            return
        }

        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .functionalStrengthTraining
        configuration.locationType = .outdoor

        session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()

        session?.delegate = self
        builder?.delegate = self
        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)

        let startDate = Date()

        session?.startActivity(with: startDate)
        try await builder?.beginCollection(at: startDate)
        started = true
    }

    func handleReceivedData(_ data: Data) throws {
        // todo what needs to be done here?
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // todo what needs to be done here?
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        // todo what needs to be done here?
    }
}
