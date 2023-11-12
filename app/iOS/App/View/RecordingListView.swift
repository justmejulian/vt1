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
        let recordingDataList = dataSource.fetchRecordingArray()

        if recordingDataList.isEmpty {
            VStack{
                Spacer()
                Text("Looks like there's no data yet...")
                Spacer()
            }
        } else {
            ScrollView {
                NavigationStack {
                    List(recordingDataList) { recordingData in
                        NavigationLink {
                            RecordingDetailView(recording: recordingData)
                        } label: {
                            VStack{
                                Text(String(recordingData.exercise))
                                    .font(.caption)
                                    .bold()
                                Text(recordingData.startTimestamp.ISO8601Format())
                                    .font(.caption2)
                                    .bold()
                            }
                        }
                    }
                        .listStyle(.automatic)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}
