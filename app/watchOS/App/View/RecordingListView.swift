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
    @Query var recordingDataList: [Recording]
    
    var body: some View {
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
            // todo use this in other places
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
