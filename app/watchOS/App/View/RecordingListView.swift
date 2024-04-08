//
//  ListView.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 25.10.2023.
//
import SwiftUI
import SwiftData
import OSLog
import Foundation

struct RecordingListView: View {
    let dataSource: DataSource

    var body: some View {

        let recordingDataList = dataSource.fetchRecordingArray()

        // add lazy loading
        List(recordingDataList) { recordingData in
            VStack{
                Text(String(recordingData.exercise))
                    .font(.caption)
                    .bold()
                Text(recordingData.startTimestamp.ISO8601Format())
                    .font(.caption2)
                    .bold()
            }

        }
            .listStyle(.automatic)
            .overlay(Group {
                if recordingDataList.isEmpty {
                    Text("Oops, looks like there's no data...")
                }
            })
            .onAppear {
                Logger.viewCycle.info("RecordingListView Appeared!")
            }
    }
}
