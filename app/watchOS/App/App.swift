//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI
import SwiftData
import HealthKit
import OSLog


let workoutManager = WorkoutManager()

let connectivityManager = ConnectivityManager()

@main
struct Main: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    let dataSource: DataSource
    let sessionManager: SessionManager
    
    init() {
        self.dataSource = DataSource()
        self.sessionManager = SessionManager(workoutManager: workoutManager, dataSource: dataSource, connectivityManager: connectivityManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(sessionManager: sessionManager, dataSource: dataSource)
        }.modelContainer(dataSource.getModelContainer())
    }
}

class AppDelegate: NSObject, WKApplicationDelegate {
    func handle(_ workoutConfiguration: HKWorkoutConfiguration) {
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
