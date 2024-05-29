//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI
import SwiftData
import OSLog

struct ContentView: View {
    
    let sensorDataCount: Int
    let recordingDataCount: Int
    
    let sessionManager: SessionManager
    
    @ObservationIgnored
    let dataSource: DataSource
    
    init(sessionManager: SessionManager, dataSource: DataSource) {
        self.dataSource = dataSource
        self.sessionManager = sessionManager
        
        let  modelContext = dataSource.getModelContext()
        let descriptor = FetchDescriptor<RecordingData>()
        recordingDataCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        
        let descriptor2 = FetchDescriptor<SensorData>()
        sensorDataCount = (try? modelContext.fetchCount(descriptor2)) ?? 0
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
                    Text(String(recordingDataCount))
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Text("Batch #: ")
                        .font(.caption)
                        .bold()
                    Text(String(sensorDataCount))
                        .font(.caption)
                }
                Spacer()
            }
            
            Spacer()
            Spacer()
            
            VStack {
                List {
                    NavigationLink {
                        RecordingListView(dataSource: dataSource)
                    } label: {
                        Text("Recordings")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
            }.padding(.bottom, 32).padding(.horizontal, 20)

            Spacer()

            VStack {
                NavigationLink {
                    StartRecordingView(dataSource: dataSource, sessionManager: sessionManager)
                } label: {
                    Label("New Recording", systemImage: "plus")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }.buttonStyle(BorderedProminentButtonStyle())

                NavigationLink {
                    SyncView(dataSource: dataSource)
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
    }

}
