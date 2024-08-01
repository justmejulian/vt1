//
//  ListsView.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 01.08.2024.
//

import Foundation
import SwiftUI
import OSLog

struct ListsView: View {
    var body: some View {
        NavigationStack {
            NavigationLink {
                RecordingListView()
            } label: {
                Label("Unsynced Recordings", systemImage: "list.bullet")
            }
            NavigationLink {
                LogsView()
            } label: {
                Label("Logs", systemImage: "list.bullet")
            }
        }
        .listStyle(.plain)
        .navigationTitle("Color")
        .onAppear {
            Logger.viewCycle.info("ListsView Appeared!")
        }
    }
}
