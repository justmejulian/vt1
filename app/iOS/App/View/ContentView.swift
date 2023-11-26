//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @ObservedObject
    private var connectivityManager = ConnectivityManager.shared
    
    @Query
    var sensorData: [SensorData]
    
    @Query
    var recordingData: [RecordingData]

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
                    Text("Connected")
                        .font(.caption)
                        .bold()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(connectivityManager.isConnected ? .green : .gray)
                }
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

            RecordingListView()

            Spacer()

            VStack {
                NavigationLink {
                    StartRecordingView()
                } label: {
                    Label("New Recording", systemImage: "plus")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedProminentButtonStyle())

                NavigationLink {
                    SyncView()
                } label: {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedButtonStyle())
            }.padding(.bottom, 32).padding(.horizontal, 20)
        }
    }

}
