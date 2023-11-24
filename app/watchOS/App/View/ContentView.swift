//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var recordingManager = RecordingManager()

    //todo add connection state

    var body: some View {
        NavigationStack {
            switch recordingManager.isRecording {
            case false :
                    NavigationLink {
                        MotionView()
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
                        SyncView()
                    } label: {
                        Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                    }.buttonStyle(.borderedProminent)

            case true:
                MotionView()
            }
        }
        .listStyle(.plain)
        .navigationTitle("Color")
    }
}
