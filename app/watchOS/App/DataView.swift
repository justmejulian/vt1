//
//  Created by Julian Visser on 23.10.2023.
//

import SwiftUI
import SwiftData

struct DataView: View {
    
    @Environment(\.modelContext) var context
    @ObservedObject var motionData = MotionData()
    
    @State private var selection = 1
    @State var started = false
    
    @State private var timeRunning = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(content: {
            
            Text("Accelerometer")
                .font(.caption)
                .bold()
            HStack(content: {
                Text("X: \(motionData.Acceleration.x, specifier: "%.2f")")
                    .font(.caption2)
                Text("Y: \(motionData.Acceleration.y, specifier: "%.2f")")
                    .font(.caption2)
                Text("Z: \(motionData.Acceleration.z, specifier: "%.2f")")
                    .font(.caption2)
            })
            
            Spacer()
            
            Text("Gyroscope")
                .font(.caption)
                .bold()
            HStack(content: {
                Text("X: \(motionData.Gyroscope.x, specifier: "%.2f")")
                    .font(.caption2)
                Text("Y: \(motionData.Gyroscope.y, specifier: "%.2f")")
                    .font(.caption2)
                Text("Z: \(motionData.Gyroscope.z, specifier: "%.2f")")
                    .font(.caption2)
            })
            
            Spacer()
            
            HStack {
                Text("Time:")
                    .frame(maxWidth: .infinity)
                    .font(.caption2)
                    .bold()
                Text("\(timeRunning)")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.caption2)
            }
            
            Button(action: handleButton) {
                Text(started ? "Stop" : "Start")
                    .font(.title2)
            }
                .background(started ? Color.red : Color.blue)
                .clipShape(Capsule())
                .padding(.all)
        })
    }
    
    func handleButton() {
        if started {
            started = false
            timer?.invalidate()
        } else {
            timeRunning = 0
            self.started = true
            @Bindable var recording = RecordingData(exercise: "testsquat")
            context.insert(recording)
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                timeRunning += 1
                let date = Date()
                let gyroSensorData = SensorData(timestamp: date, sensor_id: "c8ddbb1d-7395-4892-bc5e-30923b7c0de4", x: motionData.Gyroscope.x, y: motionData.Gyroscope.y, z: motionData.Gyroscope.z)
                let acceSensorData = SensorData(timestamp: date, sensor_id: "f1e8e57a-b350-4450-9d5a-4fc13410afcc", x: motionData.Acceleration.x, y: motionData.Acceleration.y, z: motionData.Acceleration.z)
                print("Adding data to context")
                recording.sensorData.append(gyroSensorData)
                recording.sensorData.append(acceSensorData)
            }
        }
    }
}

#Preview {
    DataView()
}
