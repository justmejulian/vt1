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
    @State private var loading = true
    
    init(db: Database) {
        self.db = db
        self.recordingListViewModel = RecordingListViewModel(db: db)
        self.recordings = []
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
            .overlay(Group {
                if loading {
                    SpinnerView()
                }
                if !loading && recordings.isEmpty {
                    Text("Oops, looks like there's no data...")
                }
            })
            .task(priority: .background) {
                Logger.viewCycle.debug("Running Task")
                updateList()
            }
            .refreshable {
                updateList()
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
    }
    
    func updateList() {
        self.loading = true
        let temp: [Recording] = db.fetchData()
        self.recordings = temp.sorted {
            $0.startTimestamp > $1.startTimestamp
        }
        self.loading = false
    }
}
