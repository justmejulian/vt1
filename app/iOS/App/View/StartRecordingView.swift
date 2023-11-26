//
//  Created by Julian Visser on 27.10.2023.
//

import Foundation
import SwiftUI
import SwiftData

import HealthKit

struct StartRecordingView: View {
    @ObservedObject
    private var connectivityManager = ConnectivityManager.shared
    @ObservationIgnored
    private let workoutManager = WorkoutManager.shared
    
    @Query
    var sensorData: [SensorData]
    
    @Query
    var recordingData: [RecordingData]

    @State private var text: String = ""

    @State private var isRequestCompleted = true

    var body: some View {
        VStack(content: {
            Spacer()
            
            Text("Start New Recording")
                .font(.largeTitle)
                .padding(.all)
            
            HStack {
                Spacer()
                VStack {
                    Text("Connected")
                        .font(.caption)
                        .bold()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(connectivityManager.isConnected ? .green : .gray)
                }
                Spacer()
                VStack {
                    Text("Recording #: ")
                        .font(.caption)
                        .bold()
                    Text(String(recordingData.count))
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Text("Data Point #: ")
                        .font(.caption)
                        .bold()
                    Text(String(sensorData.count))
                        .font(.caption)
                }
                Spacer()
            }
            
            Spacer()
            
            VStack(content: {
                Text("Enter Exercise Name:")
                    .font(.title3)
                TextField("Default", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)
            })
                .padding(.all)
            
            Spacer()
            
            Button(action: start) {
                Text("Start Recording")
                    .font(.title2)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
                .buttonStyle(.borderedProminent)
                .disabled(!isRequestCompleted)
                .padding(.all)
            
            Spacer()
        })
    }

    private func start() {
        Task {
            do {
                try await workoutManager.startWatchWorkout()
                connectivityManager.sendStartSession(exerciseName: text)
            } catch {
                print(error)
            }
        }
    }
}
