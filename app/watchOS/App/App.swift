//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI
import SwiftData

@main
struct Main: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let workoutManager = WorkoutManager.shared
    
    let modelContainer = DataSource.shared.getModelContainer()
    let connectivityManager = ConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(modelContainer)
    }
}
