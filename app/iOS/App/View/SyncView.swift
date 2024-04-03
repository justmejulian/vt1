//
//  Created by Julian Visser on 20.11.2023.
//

import Foundation
import SwiftUI
import SwiftData
import OSLog

struct SyncView: View {
    
    @ObservationIgnored
    private let syncViewModel = SyncViewModel()
    
    @Query var sensorData: [SensorData]
    @Query var recordingData: [RecordingData]

    @State private var ip: String = "192.168.1.251:8080"
    
    @State private var isConfirming = false

    var body: some View {
        
        let valluesCount = sensorData.reduce(0) { $0 + $1.values.count }
        
        VStack{
            Text("Sync Data")
                .font(.largeTitle)
                .padding(.all)
            VStack{
                HStack {
                    Text("Recording #: ")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(recordingData.count))
                        .font(.title3)
                }.padding(.all)
                HStack {
                    Text("Data #")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(valluesCount))
                        .font(.title3)
                }.padding(.all)
                HStack {
                    Text("Batch #")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(sensorData.count))
                        .font(.title3)
                }.padding(.all)
            }.padding(.all)

            Spacer()

            VStack(content: {
                TextField("Enter IP:", text: $ip)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)
            }).padding(.all)

            VStack {
                Button(action: {
                    Logger.viewCycle.info("Calling postData from SyncView")
                    syncViewModel.postData(ip: ip)
                }) {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled(ip == "")

                Button(action: {
                    isConfirming = true
                }) {
                    Label("Delete All", systemImage: "trash")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedButtonStyle())
                    .confirmationDialog(
                               "Are you sure you want delete all?",
                               isPresented: $isConfirming
                    ) {
                        Button("Delete All", role: .destructive) {
                            syncViewModel.deleteAll()
                        }
                        Button("Cancel", role: .cancel) {}
                    }
            }.padding(.bottom, 32).padding(.horizontal, 20)
        }
        .onAppear {
            Logger.viewCycle.info("SyncView Appeared!")
        }
    }
}
