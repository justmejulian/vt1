//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI
import SwiftData
import OSLog

struct ContentView: View {
    
    @Query
    var sensorData: [SensorData]
    
    @Query
    var recordingData: [RecordingData]

    let sessionManager: SessionManager
    
    @ObservationIgnored
    let dataSource: DataSource

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
                    Text(String(recordingData.count))
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Text("Data Point #: ")
                        .font(.caption)
                        .bold()
                    Text(String(sensorData.count))
                        .font(.caption)
                }
                Spacer()
            }
            
            Spacer()
            Spacer()
            
            Text("Unsynced Data")
                .font(.title3)
                .bold()
                .padding(.top, 32)
            
            Spacer()

            RecordingListView(dataSource: dataSource)

            Spacer()

            VStack {
                NavigationLink {
                    StartRecordingView(sessionManager: sessionManager)
                } label: {
                    Label("New Recording", systemImage: "plus")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedProminentButtonStyle())

                NavigationLink {
                    SyncView(dataSource: dataSource)
                } label: {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedButtonStyle())
            }.padding(.bottom, 32).padding(.horizontal, 20)
        }
        .onAppear {
            Logger.viewCycle.info("ContentView Appeared!")
        }
    }

}
