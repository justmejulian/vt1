//
//  Created by Julian Visser on 27.10.2023.
//

import SwiftUI
import SwiftData
import OSLog
import Foundation

struct RecordingListView: View {
    @ObservationIgnored
    let db: Database
    
    var recordingListViewModel: RecordingListViewModel
    
    @State var recordings: [Recording]
    
    @State private var isConfirming = false
    @State private var searchText: String = ""
    
    init(db: Database) {
        self.db = db
        self.recordingListViewModel = RecordingListViewModel(db: db)
        self.recordings = []
    }
    
    func updateRecordings() {
        do {
            self.recordings = try db.fetchData()
        } catch {
            Logger.viewCycle.error("Failed to fetch recording \(error)")
            self.recordings = []
        }

    }
    
    var filteredRecordings: [Recording] {
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
                updateRecordings()
            }
        } else {
            NavigationStack {
                List(filteredRecordings) { recordingData in
                    NavigationLink {
                        RecordingDetailView(recording: recordingData, db: db)
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
                updateRecordings()
            }
        }
    }
}
