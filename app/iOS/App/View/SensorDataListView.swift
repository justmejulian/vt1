//
//  Created by Julian Visser on 06.11.2023.
//

import SwiftUI
import SwiftData

import Foundation

struct SensorDataListView: View {
    let sensorDataList: [SensorData]

    var body: some View {
        List(sensorDataList) { sensorData in
            HStack{
                VStack{
                    Text(String(sensorData.sensor_id))
                        .font(.caption)
                        .bold()
                    HStack(content: {
                        Text("X: \(sensorData.x, specifier: "%.2f")")
                            .font(.caption2)
                        Text("Y: \(sensorData.y, specifier: "%.2f")")
                            .font(.caption2)
                        Text("Z: \(sensorData.z, specifier: "%.2f")")
                            .font(.caption2)
                    })
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10, weight: .light))
            }
        }
        .listStyle(.automatic)
        .overlay(Group {
            if sensorDataList.isEmpty {
                Text("Oops, looks like there's no data...")
            }
        })
    }
}
