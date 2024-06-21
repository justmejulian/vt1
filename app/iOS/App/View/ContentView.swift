//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI
import SwiftData
import OSLog

struct ContentView: View {
    @ObservationIgnored
    let sessionManager: SessionManager
    
    @ObservationIgnored
    var db: Database
    
    @State var sensorValueCount: Int = 0
    @State var recordingCount: Int = 0
    
    init(sessionManager: SessionManager, db: Database) {
        self.db = db
        self.sessionManager = sessionManager
    }

    var body: some View {
        NavigationStack {
            Text("VT 1")
                .font(.largeTitle)
                .bold()
                .padding(.top, 32)
            
            Spacer()
            Spacer()
            
            HStack {
                Spacer()
                VStack {
                    Text("Recording #: ")
                        .font(.caption)
                        .bold()
                    Text(String(recordingCount))
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Text("Batch #: ")
                        .font(.caption)
                        .bold()
                    Text(String(sensorValueCount))
                        .font(.caption)
                }
                Spacer()
            }
            
            Spacer()
            Spacer()
            
            VStack {
                List {
                    NavigationLink {
                        RecordingListView(db: db)
                    } label: {
                        Text("Recordings")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    NavigationLink {
                        LogsView()
                    } label: {
                        Text("View Logs")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
            }.padding(.bottom, 32).padding(.horizontal, 20)

            Spacer()

            VStack {
                NavigationLink {
                    StartRecordingView(sessionManager: sessionManager)
                } label: {
                    Label("New Recording", systemImage: "plus")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(BorderedProminentButtonStyle())

                NavigationLink {
                    SyncView(db: db)
                } label: {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(BorderedButtonStyle())
            }.padding(.bottom, 32).padding(.horizontal, 20)
        }
        .onAppear {
            Logger.viewCycle.info("ContentView Appeared!")
        }
        .task {
            self.sensorValueCount = db.fetchDataCount(for: SensorBatch.self)
            self.recordingCount = db.fetchDataCount(for: Recording.self)
        }
    }

}
