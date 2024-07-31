//
//  Created by Julian Visser on 27.10.2023.
//

import Foundation
import SwiftUI
import SwiftData
import HealthKit
import OSLog
import AlertToast

struct StartRecordingView: View {
    
    @ObservedObject
    var sessionManager: SessionManager
    
    @State private var text: String = ""
    
    init(sessionManager: SessionManager){
        self.sessionManager = sessionManager
    }

    var body: some View {
        // todo add pull down to refersch state, throw error if not possible
        
        // todo move these into @State
        let disabled = ((text == "") && sessionManager.isSessionRunning == false) || sessionManager.isLoading == true
        let color = sessionManager.isSessionRunning ? Color.red : .blue
        let label = sessionManager.isSessionRunning ? "Stop Recording" : "Start Recording"
        
        VStack(content: {
            Spacer()
            
            Text("Start New Recording")
                .font(.largeTitle)
                .padding(.all)
            
            VStack{
                HStack {
                    Text("Recording Startime")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(sessionManager.recording?.startTimestamp.ISO8601Format() ?? ""))
                        .font(.title3)
                }.padding(.all)
                HStack {
                    // todo use some var in session for this
                    Text("Recorded Values: ")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(sessionManager.sensorValueCount))
                        .font(.title3)
                }.padding(.all)
            }.padding(.all)

            VStack(content: {
                TextField("Enter Exercise Name:", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)
                    .disabled(sessionManager.isSessionRunning == true)
            }).padding(.all)

            Button(action: {
                Logger.viewCycle.info("Calling toggle from StartRecordingView")
                Task {
                    // todo disable
                    await sessionManager.toggle(text: text)
                    // also try alert
                    // https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-an-alert
                }
            }) {
                Label(label, systemImage: "arrow.triangle.2.circlepath")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .disabled(disabled)
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 32).padding(.horizontal, 20)
            .tint(color)

            Spacer()
            Spacer()
        })
        .toast(isPresenting: $sessionManager.hasError){
            return AlertToast(type: .regular, title: sessionManager.errorMessage, style: .style(backgroundColor: .red))
        }
        .onAppear {
            Logger.viewCycle.info("StartRecordingView Appeared!")
            // todo do this in task
            sessionManager.refreshSessionState()
        }
    }
}
