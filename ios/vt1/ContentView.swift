//
//  ContentView.swift
//  vt1
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
    
    @ObservedObject var motionData = MotionData()
    
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
                Text("Accelerometer Data")
                    .font(.title)
                
                Text("X-Acceleration: \(motionData.Acceleration.x, specifier: "%.2f")")
                Text("Y-Acceleration: \(motionData.Acceleration.y, specifier: "%.2f")")
                Text("Z-Acceleration: \(motionData.Acceleration.z, specifier: "%.2f")")
                
                Spacer()
                Text("Gyroscope Data")
                    .font(.title)
                
                Text("X-Gyroscope: \(motionData.Gyroscope.x, specifier: "%.2f")")
                Text("Y-Gyroscope: \(motionData.Gyroscope.y, specifier: "%.2f")")
                Text("Z-Gyroscope: \(motionData.Gyroscope.z, specifier: "%.2f")")
                
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
        let data = [
            "timestamp": Date().timeIntervalSince1970,
            "device_id": "30D1E9CF-4773-4EA6-8DCE-D9B16ADB47C6",
            "sensor_id": "8ad3fb4a-6d30-4104-b1b9-f51f970423b1",
            "x": motionData.Gyroscope.x,
            "y": motionData.Gyroscope.y,
            "z": motionData.Gyroscope.z
        ] as [String : Any]
        networkViewModel.postDataToAPI(data: data) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                isRequestCompleted = true
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
