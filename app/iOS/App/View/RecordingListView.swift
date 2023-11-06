//
//  Created by Julian Visser on 27.10.2023.
//

import SwiftUI
import SwiftData

import Foundation

struct RecordingListView: View {
    @ObservationIgnored
    private let dataSource = DataSource.shared

    var body: some View {
        let recordingDataList = dataSource.fetchRecordings()

        NavigationStack {
            List(recordingDataList) { recordingData in
                NavigationLink {
                    SensorDataListView(sensorDataList: recordingData.sensorData)
                } label: {
                    HStack{
                        VStack{
                            Text(String(recordingData.exercise))
                                .font(.caption)
                                .bold()
                            if recordingData.sensorData.isEmpty {
                                Text("Oops, No sensordata").font(.footnote)
                            } else {
                                Text(String(recordingData.sensorData[0].timestamp.ISO8601Format())).font(.footnote)
                        }
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10, weight: .light))
                }
                }
            }
            .listStyle(.automatic)
            .overlay(Group {
                if recordingDataList.isEmpty {
                    Text("Oops, looks like there's no data...")
                }
            })
        }
    }
}
