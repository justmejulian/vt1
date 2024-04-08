//
//  Created by Julian Visser on 23.10.2023.
//

import SwiftUI
import SwiftData
import OSLog

struct MotionView: View {

    @ObservedObject
    var sessionManager: SessionManager
    
    @Query
    var sensorData: [SensorData]

    var body: some View {
        VStack(content: {
            if sessionManager.started {
                Spacer()
                Spacer()
                Spacer()
            }
            VStack {
                Text(sessionManager.exerciseName ?? " ")
                .font(.caption)
                .bold()
            }
            Spacer()
            VStack {
                Text("Data Point #:")
                .font(.caption)
                .bold()
                Text(String(sessionManager.sensorDataCount))
                .font(.caption)
            }
            Spacer()
            Spacer()
            HStack {
                Text("Time:")
                    .frame(maxWidth: .infinity)
                    .font(.caption2)
                    .bold()
                Text("\(sessionManager.timeCounter)")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.caption2)
            }
            Spacer()
            Button(action: sessionManager.toggle) {
                Text(sessionManager.loading
                     ? "Loading"
                     : sessionManager.started ? "Stop" : "Start")
                    .font(.title2)
            }
            .disabled(sessionManager.loading)
            .background(
                sessionManager.loading
                    ? Color.gray
                    : sessionManager.started
                        ? Color.red
                        : Color.blue
            )
                .clipShape(Capsule())
                .padding(.all)
        })
        .navigationBarBackButtonHidden(sessionManager.started)
        .onAppear {
            Logger.viewCycle.info("MotionView Appeared!")
        }
    }

}
