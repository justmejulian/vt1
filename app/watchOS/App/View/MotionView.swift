//
//  Created by Julian Visser on 23.10.2023.
//

import SwiftUI
import SwiftData

struct MotionView: View {

    @ObservedObject var sessionManager = SessionManager.shared

    var body: some View {
        VStack(content: {
            VStack {
            Text("Time:")
                .font(.caption)
                .bold()
            }
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
            Button(action: sessionManager.toggle) {
                Text(sessionManager.started ? "Stop" : "Start")
                    .font(.title2)
            }
            .background(sessionManager.started ? Color.red : Color.blue)
                .clipShape(Capsule())
                .padding(.all)
        })
        .navigationBarBackButtonHidden(sessionManager.started)
        .onAppear {
            // todo
            // motionViewModel.requestAuthorization()
        }
    }

}
