//
//  Created by Julian Visser on 06.11.2023.
//

import SwiftUI
import SwiftData

import Foundation

struct RecordingDetailView: View {
    @ObservationIgnored
    private let dataSource = DataSource.shared

    var recording: RecordingData

    var body: some View {

        let sensorDataList = dataSource.fetchSensorDataArray(timestamp: recording.startTimestamp)
        // todo filter for different sensors
        VStack{
            Text("Recording: ")
                .font(.title)
                .bold()
            Text(recording.startTimestamp.ISO8601Format())
                .font(.title)

            Spacer()

            Text("# of datapoints: " + String(sensorDataList.count))
                .font(.title2)

            Spacer()
        }
    }
}
