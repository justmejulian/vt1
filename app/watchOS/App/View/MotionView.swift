//
//  Created by Julian Visser on 23.10.2023.
//

import SwiftUI
import SwiftData

struct MotionView: View {

    @ObservedObject var motionViewModel = MotionViewModel()

    var body: some View {
        VStack(content: {
            Spacer()
            HStack {
                Text("Time:")
                    .frame(maxWidth: .infinity)
                    .font(.caption2)
                    .bold()
                Text("\(motionViewModel.timeCounter)")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.caption2)
            }
            Button(action: motionViewModel.toggle) {
                Text(motionViewModel.started ? "Stop" : "Start")
                    .font(.title2)
            }
            .background(motionViewModel.started ? Color.red : Color.blue)
                .clipShape(Capsule())
                .padding(.all)
        }).onAppear {
            // todo
            // motionViewModel.requestAuthorization()
        }
    }

}
