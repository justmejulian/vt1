//
//  Created by Julian Visser on 27.10.2023.
//

import Foundation
import SwiftUI
import SwiftData
import HealthKit
import OSLog

struct StartRecordingView: View {
    @ObservedObject
    private var sessionManager = SessionManager.shared

    @Query
    var sensorData: [SensorData]
    
    @Query
    var recordingData: [RecordingData]

    @State private var text: String = ""

    var body: some View {
        
        VStack(content: {
            Spacer()
            
            Text("Start New Recording")
                .font(.largeTitle)
                .padding(.all)
            
            VStack{
                HStack {
                    Text("Recording #: ")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(recordingData.count))
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
                    Logger.viewCycle.info("Calling toggle from StartRecordingView")
                    // todo disable
                    await sessionManager.toggle(text: text)
                    
                    // also try alert
                    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-an-alert
                }
            }) {
                Label(sessionManager.isSessionRunning ?? false ? "Stop Recording" : "Start Recording", systemImage: "arrow.triangle.2.circlepath")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .disabled(((text == "") && sessionManager.isSessionRunning == false) || sessionManager.isSessionRunning == nil || sessionManager.isLoading == true)
                .buttonStyle(BorderedProminentButtonStyle())
                .padding(.bottom, 32).padding(.horizontal, 20)
        })
        .onAppear {
            Logger.viewCycle.info("StartRecordingView Appeared!")
            sessionManager.refreshSessionState()
        }
    }
}
