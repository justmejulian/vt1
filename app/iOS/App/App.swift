//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct Main: App {

    let connectivityManager: ConnectivityManager
    let db: Database
    let sessionManager: SessionManager
    let workoutManager: WorkoutManager

    init() {
        do {
            // todo move this into Database
            let schema =  Schema([
                Recording.self,
                SensorBatch.self,
                SyncData.self,
                CompressedData.self
            ])
            self.db = Database(modelContainer: try ModelContainer(for: schema))
            self.connectivityManager = ConnectivityManager()
            self.workoutManager = WorkoutManager()
            self.sessionManager = SessionManager(workoutManager: workoutManager,  connectivityManager: connectivityManager, db: db)
        } catch {
            Logger.statistics.error("Fatal Error creating IOS App \(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(sessionManager: sessionManager, db: db)
        }.modelContainer(db.getModelContainer())
    }
}
