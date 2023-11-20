
//
//  Created by Julian Visser on 20.11.2023.
//

import Foundation
import SwiftUI
import SwiftData

struct SyncView: View {
    @ObservationIgnored
    private let networkManager = NetworkViewModel()

    @Query var sensorData: [SensorData]
    @Query var recordings: [RecordingData]
    


    var body: some View {
        
        let valluesCount = sensorData.reduce(0) { $0 + $1.values.count }
        
        VStack{
            HStack {
                Text("Recordings")
                Text(String(recordings.count))
            }
            HStack {
                Text("Sensor batches")
                Text(String(sensorData.count))
            }
            HStack {
                Text("Sensor values")
                Text(String(valluesCount))
            }
            Button(action: {
                networkManager.postDataToAPI(sensorData)
            }) {
                Text("Sync")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(.borderedProminent)
                .padding(.all)
        }
    }
}
