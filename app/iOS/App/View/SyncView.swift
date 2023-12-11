
//
//  Created by Julian Visser on 20.11.2023.
//

import Foundation
import SwiftUI
import SwiftData

struct SyncView: View {
    
    @ObservationIgnored
    private let networkManager = NetworkViewModel()
    @ObservationIgnored
    private let dataSource = DataSource.shared

    @Query var sensorData: [SensorData]
    @Query var recordingData: [RecordingData]
    

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
            
            // todo add response message: failed / synced 10, 5 new
            
            Spacer()
            VStack {
                Button(action: {
                    postData()
                }) {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedProminentButtonStyle())
            }.padding(.bottom, 32).padding(.horizontal, 20)
        }
    }

    func postData(){
        Task{
            recordingData.forEach {recording in
                print(recording)
                networkManager.postRecordingToAPI(recording, handleSuccess: { data in dataSource.removeData(recording)})
            }
        }
        Task{
            sensorData.forEach {sensor in
                print(sensor)
                networkManager.postSensorDataToAPI(sensor, handleSuccess: { data in dataSource.removeData(sensor)})
            }
        }
    }
}
