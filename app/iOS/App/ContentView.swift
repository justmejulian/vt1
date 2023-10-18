//
//  Created by Julian Visser on 16.10.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var items: [Item]

    @State private var text: String = ""
    
    @StateObject private var networkViewModel = NetworkViewModel()
    
    @State private var isRequestCompleted = true
    
    var body: some View {
        VStack(content: {
            Text("VT1 2023")
                .font(.largeTitle)
                .padding(.all)
            VStack(content: {
                Spacer()
                Text("Exercise")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                TextField("Squat", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)
                
                Spacer()
            })
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                .padding(.all)
            Button(action: addItem) {
                Text("Send current")
                    .font(.title2)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
                .buttonStyle(.borderedProminent)
                .disabled(!isRequestCompleted)
                .padding(.all)
            Button(action: addItem) {
                Text("Sync")
                    .font(.title2)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
                .buttonStyle(.bordered)
                .padding(.all)
        })
    }

    private func addItem() {
        isRequestCompleted = false
    }

    private func deleteItems(offsets: IndexSet) {
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
