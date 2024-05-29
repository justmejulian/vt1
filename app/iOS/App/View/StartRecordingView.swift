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
    var sessionManager: SessionManager

    @State private var text: String = ""
    
    let sensorDataCount: Int
    let recordingDataCount: Int
    
    init(dataSource: DataSource, sessionManager: SessionManager){
        
        self.sessionManager = sessionManager
        
        let  modelContext = dataSource.getModelContext()
        let descriptor = FetchDescriptor<RecordingData>()
        self.recordingDataCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        
        let descriptor2 = FetchDescriptor<SensorData>()
        self.sensorDataCount = (try? modelContext.fetchCount(descriptor2)) ?? 0
    }

    var body: some View {
        
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
                    Text("Recording #: ")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(recordingDataCount))
                        .font(.title3)
                }.padding(.all)
                HStack {
                    // todo use some var in session for this
                    Text("Batch #")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Text(String(sensorDataCount))
                        .font(.title3)
                }.padding(.all)
            }.padding(.all)

            VStack(content: {
                TextField("Enter Exercise Name:", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)
            }).padding(.all)

            Button(action: {
                Task {
                    // todo move this into a viewModel
                    Logger.viewCycle.info("Calling toggle from StartRecordingView")
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
        .onAppear {
            Logger.viewCycle.info("StartRecordingView Appeared!")
            // todo do this in task
            sessionManager.refreshSessionState()
        }
    }
}
