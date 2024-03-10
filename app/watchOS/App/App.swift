//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI
import SwiftData

@main
struct Main: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    // why not pass to connectivityManager here?
    let sessionManager = SessionManager.shared
    
    let connectivityManager = ConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(sessionManager.modelContainer)
    }
}
