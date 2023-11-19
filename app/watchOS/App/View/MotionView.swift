//
//  Created by Julian Visser on 23.10.2023.
//

import SwiftUI
import SwiftData

struct MotionView: View {

    @ObservedObject var motionViewModel = MotionViewModel()

    var body: some View {
        VStack(content: {
            DataView(title: "Accelerometer", data: motionViewModel.acceleration)
            Spacer()
            DataView(title: "Gyroscope", data: motionViewModel.gyroscope)
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
            Button(action: {
                Task {
                    await motionViewModel.toggle()
                }
            }) {
                Text(motionViewModel.isRecording ? "Stop" : "Start")
                    .font(.title2)
            }
            .background(motionViewModel.isRecording ? Color.red : Color.blue)
                .clipShape(Capsule())
                .padding(.all)
        }).onAppear {
            motionViewModel.requestAuthorization()
        }
    }
    struct DataView: View {
        var title: String
        var data: MotionViewModel.BaseData

        var body: some View {
            Text(title)
                .font(.caption)
                .bold()
            HStack(content: {
                Text("X: \(data.x, specifier: "%.2f")")
                    .font(.caption2)
                Text("Y: \(data.y, specifier: "%.2f")")
                    .font(.caption2)
                Text("Z: \(data.z, specifier: "%.2f")")
                    .font(.caption2)
            })

        }
    }

}
