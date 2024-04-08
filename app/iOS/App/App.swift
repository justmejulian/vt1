//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI
import SwiftData

@main
struct Main: App {
    
    let connectivityManager: ConnectivityManager
    let dataSource: DataSource
    let sessionManager: SessionManager
    let workoutManager: WorkoutManager
    
    init() {
        self.connectivityManager = ConnectivityManager()
        self.dataSource = DataSource()
        self.workoutManager = WorkoutManager()
        self.sessionManager = SessionManager(workoutManager: workoutManager,  connectivityManager: connectivityManager, dataSource: dataSource)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(sessionManager: sessionManager, dataSource: dataSource)
        }.modelContainer(dataSource.getModelContainer())
    }
}
