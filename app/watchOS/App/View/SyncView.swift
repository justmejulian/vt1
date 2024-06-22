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
    @ObservationIgnored
    var sessionManager: SessionManager

    @ObservedObject
    var syncViewModel: SyncViewModel
    @Query var recordings: [Recording]
    @Query var sensorData: [SensorBatch]
    
    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        self.syncViewModel = SyncViewModel(sessionManager: sessionManager)
    }

    var body: some View {
        VStack{
            Text("Sync")
                .font(.title)
            Spacer()
            Text("# unsynced Recordings:")
                .font(.footnote)
            Text("\(recordings.count)")
                .font(.footnote)
            Text("# unsynced SensorBatch:")
                .font(.footnote)
            Text("\(sensorData.count)")
                .font(.footnote)
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
