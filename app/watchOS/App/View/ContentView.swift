//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI
import OSLog

struct ContentView: View {

    @ObservedObject
    var sessionManager: SessionManager

    @ObservationIgnored
    var db: Database
    
    let motionView:MotionView
    
    init(sessionManager: SessionManager, db: Database) {
        self.sessionManager = sessionManager
        self.db = db
        self.motionView = MotionView(sessionManager: sessionManager)
    }
    
    var body: some View {
        NavigationStack {
            switch sessionManager.started {
            case false :
                    NavigationLink {
                        motionView
                    } label: {
                        Label("New Recording", systemImage: "plus")
                    }
                    NavigationLink {
                        RecordingListView()
                    } label: {
                        Label("List of Unsynced Recordings", systemImage: "list.bullet")
                    }
                    Spacer()
                    NavigationLink {
                        SyncView(sessionManager: sessionManager)
                    } label: {
                        Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                    }.buttonStyle(.borderedProminent)

            case true:
                motionView
            }
        }
        .listStyle(.plain)
        .navigationTitle("Color")
        .onAppear {
            Logger.viewCycle.info("ContentView Appeared!")
        }
    }
}
