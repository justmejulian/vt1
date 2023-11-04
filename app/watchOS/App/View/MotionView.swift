//
//  Created by Julian Visser on 23.10.2023.
//

import SwiftUI
import SwiftData

struct MotionView: View {
    
    @Environment(\.modelContext) var context
    
    @Query() var recordingDataList: [RecordingData]
    
    @ObservedObject var motionViewModel = MotionViewModel()
    
    var body: some View {
        VStack(content: {
            DataView(title: "Accelerometer", x: motionViewModel.acceleration.x, y: motionViewModel.acceleration.y, z: motionViewModel.acceleration.z)
            Spacer()
            DataView(title: "Gyroscope", x: motionViewModel.gyroscope.x, y: motionViewModel.gyroscope.y, z: motionViewModel.gyroscope.z)
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
            
            Button(action:  motionViewModel.toggle) {
                Text(motionViewModel.isRecording ? "Stop" : "Start")
                    .font(.title2)
            }
            .background(motionViewModel.isRecording ? Color.red : Color.blue)
                .clipShape(Capsule())
                .padding(.all)
        })
    }
    
    struct DataView: View {
        
        var title: String
        
        @State var x:Double
        @State var y:Double
        @State var z:Double
        
        var body: some View {
            Text(title)
                .font(.caption)
                .bold()
            HStack(content: {
                Text("X: \(x, specifier: "%.2f")")
                    .font(.caption2)
                Text("Y: \(y, specifier: "%.2f")")
                    .font(.caption2)
                Text("Z: \(z, specifier: "%.2f")")
                    .font(.caption2)
            })

        }
    }

}
