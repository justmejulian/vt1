//
//  Created by Julian Visser on 18.10.2023.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var motionData = MotionData()
    
    @State var started = false
    
    var body: some View {
        VStack(content: {
            Text("Accelerometer")
                .font(.title2)
            Text("X: \(motionData.Acceleration.x, specifier: "%.2f")")
            Text("Y: \(motionData.Acceleration.y, specifier: "%.2f")")
            Text("Z: \(motionData.Acceleration.z, specifier: "%.2f")")
            
            Text("Gyroscope")
                .font(.title2)
            Text("X: \(motionData.Gyroscope.x, specifier: "%.2f")")
            Text("Y: \(motionData.Gyroscope.y, specifier: "%.2f")")
            Text("Z: \(motionData.Gyroscope.z, specifier: "%.2f")")
            
            Button(action: handleButton) {
                Text(started ? "Stop" : "Start")
                    .font(.title2)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
                .buttonStyle(.borderedProminent) // todo maybe change colors
                .padding(.all)
        })
    }
    
    private func handleButton() {
        started = !started
    }
}

#Preview {
    ContentView()
}
