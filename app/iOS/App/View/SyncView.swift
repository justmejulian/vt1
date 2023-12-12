
//
//  Created by Julian Visser on 20.11.2023.
//

import Foundation
import SwiftUI
import SwiftData

struct SyncView: View {
    
    @ObservationIgnored
    private let dataSource = DataSource.shared

    @Query var sensorData: [SensorData]
    @Query var recordingData: [RecordingData]

    @State private var ip: String = "192.168.1.251:8080"

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
                    postData()
                }) {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled(ip == "")

            }.padding(.bottom, 32).padding(.horizontal, 20)
        }
    }

    func postData(){
        let networkManager = NetworkViewModel(ip: ip)
        Task{
            recordingData.forEach {recording in
                networkManager.postRecordingToAPI(recording, handleSuccess: { data in dataSource.removeData(recording)})
            }
        }
        Task{
            sensorData.forEach {sensor in
                networkManager.postSensorDataToAPI(sensor, handleSuccess: { data in dataSource.removeData(sensor)})
            }
        }
    }
}
