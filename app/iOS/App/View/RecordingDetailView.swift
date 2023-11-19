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

    // add delete button
    // add why to change exercise type

    var body: some View {

        let sensorDataList = dataSource.fetchSensorDataArray(timestamp: recording.startTimestamp)
        let valluesCount = sensorDataList.reduce(0) { $0 + $1.values.count }
        // todo filter for different sensors
        VStack{
            Spacer()
            Text("Recording: ")
                .font(.title)
                .bold()
            Text(recording.startTimestamp.ISO8601Format())
                .font(.title2)
            Spacer()

            // todo count values
            Text("# of datapoints: " + String(valluesCount))
                .font(.title2)

            Spacer()
            Spacer()
        }
    }
}
