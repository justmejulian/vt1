//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI
import SwiftData

@main
struct Main: App {
    let modelContainer = DataSource.shared.getModelContainer()
    let connectivityManager = ConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(modelContainer)
    }
}
