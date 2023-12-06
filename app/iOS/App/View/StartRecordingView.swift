//
//  Created by Julian Visser on 27.10.2023.
//

import Foundation
import SwiftUI
import SwiftData
import HealthKit

struct StartRecordingView: View {
    @ObservedObject
    private var sessionManager = SessionManager.shared
    @ObservedObject
    private var connectivityManager = ConnectivityManager.shared

    @Query
    var sensorData: [SensorData]
    
    @Query
    var recordingData: [RecordingData]

    @State private var text: String = ""

    var body: some View {
        
        let valluesCount = sensorData.reduce(0) { $0 + $1.values.count }
        
        VStack(content: {
            Spacer()
            
            Text("Start New Recording")
                .font(.largeTitle)
                .padding(.all)
            
            VStack{
                HStack {
                    Text("Connected")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(connectivityManager.isConnected ? .green : .gray)
                }.padding(.all)
                HStack {
                    Text("Recording #: ")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(recordingData.count))
                        .font(.title3)
                }.padding(.all)
                HStack {
                    Text("Data #")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(valluesCount))
                        .font(.title3)
                }.padding(.all)
                HStack {
                    Text("Batch #")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(sensorData.count))
                        .font(.title3)
                }.padding(.all)
            }.padding(.all)
            
            Spacer()
            
            VStack(content: {
                TextField("Enter Exercise Name:", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)
            }).padding(.all)
            
            Spacer()
            
            Button(action: {
                Task {
                    await sessionManager.toggle(text: text)
                }
            }) {
                Label(sessionManager.isSessionRunning ?? false ? "Stop Recording" : "Start Recording", systemImage: "arrow.triangle.2.circlepath")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
                .disabled(((text == "") && sessionManager.isSessionRunning == false) || sessionManager.isSessionRunning == nil || !connectivityManager.isConnected)
                .buttonStyle(BorderedProminentButtonStyle())
                .padding(.bottom, 32).padding(.horizontal, 20)
        })
        .onAppear {
            print("StartRecordingView.onAppear")
            sessionManager.refreshSessionState()
        }
    }
}
