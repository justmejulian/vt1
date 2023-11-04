//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var started = false
    
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
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                // todo spin inco when syncing
                Label("Sync", systemImage: "arrow.triangle.2.circlepath")
            })
                .background(started ? Color.red : Color.blue)
                .clipShape(Capsule())
                .padding(.all)
        }
        .listStyle(.plain)
        .navigationTitle("Color")
    }
}

#Preview {
    ContentView()
}
