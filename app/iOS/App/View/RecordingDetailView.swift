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

    @Query
    var sensorData: [SensorData]

    @State private var text: String

    init(recording: RecordingData) {
        self.recording = recording

        self._text = State(initialValue: recording.exercise)

        self._sensorData = Query(filter: #Predicate<SensorData> {
            $0.recordingStart == recording.startTimestamp
        })
    }

    var body: some View {
        let valluesCount = sensorData.reduce(0) { $0 + $1.values.count }
        // todo filter for different sensors
        VStack{
            Spacer()
            Text("Recording: ")
                .font(.title)
                .bold()

            TextField("Exercise:", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .padding(.all)

            Text(recording.startTimestamp.ISO8601Format())
                .font(.title3)
            Spacer()

            // todo count values
            Text("# of datapoints: " + String(valluesCount))
                .font(.title2)

            Spacer()

            Button(action: {
                updateData()
            }) {
                Label("Save", systemImage: "square.and.arrow.down")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(BorderedProminentButtonStyle())

            Button(action: {
                deleteData()
            }) {
                Label("Delete", systemImage: "trash")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
                .buttonStyle(BorderedButtonStyle())
        }

    }

    func updateData() {
        recording.exercise = text
    }

    func deleteData() {
        dataSource.removeData(recording)
    }
}
