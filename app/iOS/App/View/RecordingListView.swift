//
//  Created by Julian Visser on 27.10.2023.
//

import SwiftUI
import SwiftData
import OSLog
import Foundation

struct RecordingListView: View {
    @ObservationIgnored
    let dataSource: DataSource

    @Environment(\.modelContext) var modelContext
    @Query var recordings: [RecordingData]

    var body: some View {
        if recordings.isEmpty {
            VStack{
                Spacer()
                Text("Looks like there are no Recordings yet...")
                Spacer()
            }
            .onAppear {
                Logger.viewCycle.info("RecordingListView Empty VStack Appeared!")
            }
        } else {
            NavigationStack {
                List(recordings) { recordingData in
                    NavigationLink {
                        RecordingDetailView(recording: recordingData, dataSource: dataSource)
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
            }
            .onAppear {
                Logger.viewCycle.info("RecordingListView NavigationStack Appeared!")
            }
        }
    }
}
