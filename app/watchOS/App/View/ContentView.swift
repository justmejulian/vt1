//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI

struct ContentView: View {
        
    @ObservedObject var motionViewModel = MotionViewModel()
    
    var body: some View {
        NavigationStack {
            NavigationLink {
                MotionView()
            } label: {
                Label("New Recording", systemImage: "plus")
            }
            NavigationLink {
                ListView()
            } label: {
                Label("List of Recordings", systemImage: "list.bullet")
            }
            Spacer()
            Button(action: motionViewModel.sendMessageToiPhone, label: {
                // todo spin inco when syncing
                Label("Sync", systemImage: "arrow.triangle.2.circlepath")
            })
             .buttonStyle(.borderedProminent)
        }
        .listStyle(.plain)
        .navigationTitle("Color")
    }
}

#Preview {
    ContentView()
}
