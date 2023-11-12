//
//  Created by Julian Visser on 27.10.2023.
//

import SwiftUI
import SwiftData

import Foundation

struct RecordingListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var recordings: [RecordingData]

    init() {
        print(recordings)
    }

    var body: some View {
        if recordings.isEmpty {
            VStack{
                Spacer()
                Text("Looks like there's no data yet...")
                Spacer()
            }
        } else {
            NavigationStack {
                List(recordings) { recordingData in
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
            }
        }
    }
}
