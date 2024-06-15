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
    
    var recordingListViewModel: RecordingListViewModel
    
    @Query var recordings: [RecordingData]
    
    @State private var isConfirming = false
    @State private var searchText: String = ""
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        self.recordingListViewModel = RecordingListViewModel(dataSource: dataSource)
    }
    
    var filteredRecordings: [RecordingData] {
        if searchText.isEmpty {
            recordings
        } else {
            recordings.filter { $0.exercise.localizedStandardContains(searchText) }
        }
    }
    
    var body: some View {
        Text("List of Recordings")
            .font(.title3)
            .bold()
        
        Spacer()
        
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
                List(filteredRecordings) { recordingData in
                    NavigationLink {
                        RecordingDetailView(recording: recordingData, dataSource: dataSource)
                    } label: {
                        VStack{
                            Text(recordingData.exercise)
                                .font(.caption)
                                .bold()
                            Text(recordingData.startTimestamp.ISO8601Format())
                                .font(.caption2)
                                .bold()
                        }
                    }
                }
                .listStyle(.automatic)
                .searchable(text: $searchText)
                
                Button(action: {
                    isConfirming = true
                }) {
                    Label("Delete All", systemImage: "trash")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BorderedButtonStyle())
                .confirmationDialog(
                    "Are you sure you want delete all?",
                    isPresented: $isConfirming
                ) {
                    // todo move to
                    Button("Delete All", role: .destructive) {
                        recordingListViewModel.deleteAll()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            .onAppear {
                Logger.viewCycle.info("RecordingListView NavigationStack Appeared!")
            }
        }
    }
}
