//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            Spacer()
            Spacer()
            Spacer()
            NavigationLink {
                StartRecordingView()
            } label: {
                Label("New Recording", systemImage: "plus")
            }
            Spacer()
            NavigationLink {
                RecordingListView()
            } label: {
                Label("List of Recordings", systemImage: "list.bullet")
            }
            Spacer()
            Spacer()
            Spacer()
        }
        .listStyle(.plain)
    }

}

#Preview {
    ContentView()
}
