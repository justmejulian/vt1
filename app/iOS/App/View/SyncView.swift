//
//  Created by Julian Visser on 20.11.2023.
//

import Foundation
import SwiftUI
import SwiftData
import OSLog

struct SyncView: View {
    var syncViewModel: SyncViewModel
    
    @Query var sensorData: [SensorData]
    @Query var recordingData: [RecordingData]
    @Query var syncData: [SyncData]

    @State
    var ip: String
    
    init(dataSource: DataSource) {
        syncViewModel = SyncViewModel(dataSource: dataSource)
        
        ip = syncViewModel.syncData.ip
    }

    var body: some View {
        
        VStack{
            Spacer()
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
                    Text("Batch #")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(sensorData.count))
                        .font(.title3)
                }.padding(.all)
            }.padding(.all)

            VStack(content: {
                TextField("Enter IP:", text: $ip)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)
            }).padding(.all)

            Button(action: {
                Logger.viewCycle.info("Calling postData from SyncView")
                syncViewModel.setIp(ip)
                syncViewModel.postData(ip: ip)
            }) {
                Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(BorderedProminentButtonStyle())
                .disabled(ip == "")

            Spacer()
            Spacer()
        }
        .onAppear {
            Logger.viewCycle.info("SyncView Appeared!")
        }
        .onDisappear{
            syncViewModel.setIp(ip)
        }
    }
}
