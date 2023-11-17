//
//  SyncView.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 09.11.2023.
//

import Foundation
import SwiftUI
import SwiftData

struct SyncView: View {
    @Environment(\.modelContext) var modelContext
    @Query var recordings: [RecordingData]
    @Query var sensorData: [SensorData]


    @ObservationIgnored
    private let dataSource = DataSource.shared

    @ObservationIgnored
    private let connectivityManager = ConnectivityManager.shared

    @ObservedObject var motionViewModel = MotionViewModel()

    @State var syncing = false

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
                syncing = true
                motionViewModel.sync()
                // todo reacte to no more data
                syncing = false
            }
                .buttonStyle(.borderedProminent)
                .disabled(sensorData.count <= 0 || recordings.count <= 0 || syncing)
        }
    }

}
