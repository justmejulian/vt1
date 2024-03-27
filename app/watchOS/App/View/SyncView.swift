//
//  SyncView.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 09.11.2023.
//

import Foundation
import SwiftUI
import SwiftData
import OSLog

struct SyncView: View {
    @ObservedObject
    var syncViewModel = SyncViewModel()
    @Query var recordings: [RecordingData]
    @Query var sensorData: [SensorData]

    var body: some View {
        VStack{
            Text("Sync")
                .font(.title)
            Spacer()
            Text("# unsynced Recordings: \(recordings.count)")
                .font(.caption2)
            Text("# unsynced SensorData: \(sensorData.count)")
                .font(.caption2)
            Spacer()
            Button("Sync") {
                syncViewModel.sync()
            }
                .buttonStyle(.borderedProminent)
                .disabled(sensorData.count <= 0 && recordings.count <= 0)
        }
        .onAppear {
            Logger.viewCycle.info("SyncView Appeared!")
        }
    }

}
