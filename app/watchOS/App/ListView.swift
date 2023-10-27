//
//  ListView.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 25.10.2023.
//
import SwiftUI
import SwiftData

import Foundation

struct ListView: View {
    @Query() var recordingDataList: [RecordingData]
    
    var body: some View {
        List(recordingDataList) { recordingData in
            HStack{
                VStack{
                    Text(String(recordingData.exercise))
                        .font(.caption)
                        .bold()
                    Text(String(recordingData.sensorData[0].timestamp.ISO8601Format())).font(.footnote)
                }
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10, weight: .light))
            }
        }
            .listStyle(.automatic)
            .overlay(Group {
                if recordingDataList.isEmpty {
                    Text("Oops, looks like there's no data...")
                }
            })
    }
}

#Preview {
    ListView()
}
