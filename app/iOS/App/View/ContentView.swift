//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationStack {
            Text("Recordings:")
                .font(.title)
                .bold()
                .padding(.top, 32)

            Spacer()

            RecordingListView()

            Spacer()

            HStack {
                NavigationLink {
                    StartRecordingView()
                } label: {
                    Label("New Recording", systemImage: "plus")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedProminentButtonStyle())

                NavigationLink {
                    SyncView()
                } label: {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                    .buttonStyle(BorderedButtonStyle())
            }.padding(.bottom, 32).padding(.horizontal, 20)
        }
    }

}

#Preview {
    ContentView()
}
