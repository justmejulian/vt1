
//
//  Created by Julian Visser on 20.11.2023.
//

import Foundation
import SwiftUI
import SwiftData

struct SyncView: View {
    @ObservedObject
    private var connectivityManager = ConnectivityManager.shared
    
    @ObservationIgnored
    private let networkManager = NetworkViewModel()

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
                    Text("Connected")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(connectivityManager.isConnected ? .green : .gray)
                }.padding(.all)
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
                    networkManager.postDataToAPI(sensorData)
                }) {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedProminentButtonStyle())
                
                Button(action: {
                    print("Export data to local")
                }) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedButtonStyle())
                
            }.padding(.bottom, 32).padding(.horizontal, 20)
        }
    }
}
