//
//  Created by Julian Visser on 27.10.2023.
//

import Foundation
import SwiftUI

import HealthKit

struct StartRecordingView: View {
    @ObservationIgnored
    private let connectivityManager = ConnectivityManager.shared
    @ObservationIgnored
    private let workoutManager = WorkoutManager.shared

    @State private var text: String = ""

    @State private var isRequestCompleted = true

    var body: some View {
        VStack(content: {
            Text("VT1 2023")
                .font(.largeTitle)
                .padding(.all)
            VStack(content: {
                Spacer()
                Text("Exercise")
                    .font(.title)
                TextField("Squat", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)

                Spacer()
            })
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                .padding(.all)
            Button(action: start) {
                Text("Start Recording")
                    .font(.title2)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
                .buttonStyle(.borderedProminent)
                .disabled(!isRequestCompleted)
                .padding(.all)
        })
    }

    private func start() {
        Task {
            do {
                try await workoutManager.startWatchWorkout()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    StartRecordingView()
}
