//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI
import SwiftData
import HealthKit
import OSLog



@main
struct Main: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    let db: Database
    let sessionManager: SessionManager

    init() {
        do {
            let schema =  Schema([
                Recording.self,
                SensorBatch.self,
            ])
            self.db = Database(modelContainer: try ModelContainer(for: schema))
            self.sessionManager = SessionManager(db: db)
        } catch {
            Logger.statistics.error("Fatal Error creating watchOs App \(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(sessionManager: sessionManager, db: db)
        }.modelContainer(db.getModelContainer())
    }
}

class AppDelegate: NSObject, WKApplicationDelegate {
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
        let workoutManager = WorkoutManager.shared
        let connectivityManager = ConnectivityManager.shared
        Logger.viewCycle.info("AppDelegate: handle")
        Task {
            do {
                Logger.viewCycle.debug("calling resetWorkout from AppDelegate")
                workoutManager.resetWorkout()
                Logger.viewCycle.debug("calling startWorkout from AppDelegate")
                try await workoutManager.startWorkout()
                
                // todo send info to iphone to start session
                connectivityManager.sendSessionReadyToStart()
            } catch {
                Logger.viewCycle.error("Failed stating workout from AppDelegate")
            }
        }
    }
}
