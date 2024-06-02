//
//  Created by Julian Visser on 23.10.2023.
//

import SwiftUI
import SwiftData
import OSLog

struct MotionView: View {

    @ObservedObject
    var sessionManager: SessionManager

    var body: some View {
        
        let loading = self.sessionManager.loadingMap.contains(where: { $0.value == true})
        
        let text = loading ? "Loading" : sessionManager.started ? "Stop" : "Start"
        
        let color = loading ? Color.gray : sessionManager.started ? Color.red : Color.blue
        
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
                Text("\(sessionManager.timeManager.counter)")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.caption2)
            }
            Spacer()
            Button(action: sessionManager.toggle) {
                Text(text)
                    .font(.title2)
            }
            .disabled(loading)
            .background(color)
                .clipShape(Capsule())
                .padding(.all)
        })
        .navigationBarBackButtonHidden(sessionManager.started)
        .onAppear {
            Logger.viewCycle.info("MotionView Appeared!")
        }
    }

}
