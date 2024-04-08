//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI
import OSLog

struct ContentView: View {

    @ObservedObject
    var sessionManager: SessionManager

    @ObservationIgnored
    var dataSource: DataSource
    
    var body: some View {
        NavigationStack {
            switch sessionManager.started {
            case false :
                    NavigationLink {
                        MotionView(sessionManager: sessionManager)
                    } label: {
                        Label("New Recording", systemImage: "plus")
                    }
                    NavigationLink {
                        RecordingListView(dataSource: dataSource)
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
                MotionView(sessionManager: sessionManager)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Color")
        .onAppear {
            Logger.viewCycle.info("ContentView Appeared!")
        }
    }
}
