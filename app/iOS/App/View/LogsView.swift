//
//  File.swift
//  vt1 Mobile App
//
//  Created by Julian Visser on 15.06.2024.
//

import Foundation
import SwiftUI
import OSLog

struct LogsView: View {
    
    @State
    var entries: [LogEntry] = []
    
    @State var loading = true
    
    var body: some View {
        List(entries, id: \.id) { logEntry in
            VStack(alignment: .leading) {
                HStack {
                    Text(logEntry.date.ISO8601Format())
                        .font(.caption)
                    Text(logEntry.category)
                        .font(.caption2)
                }
                Text(logEntry.message)
            }
        }
        .overlay(Group {
            if loading {
                SpinnerView()
            }
            if !loading && entries.isEmpty {
                Text("Oops, looks like there's no data...")
            }
        })
        .task(priority: .background) {
            // add sleep to that view can update
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
                Logger.viewCycle.error("Failed to Sleep in task")
            }
            updateLogs()
        }
        .refreshable {
            updateLogs()
        }
        .navigationBarBackButtonHidden(self.loading)
    }
    
    func updateLogs() {
        self.loading = true
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position = store.position(timeIntervalSinceLatestBoot: 10)
            self.entries  = try store
                .getEntries(at: position)
                .compactMap { $0 as? OSLogEntryLog }
                .filter { $0.subsystem == Bundle.main.bundleIdentifier! }
                .map { LogEntry(date: $0.date, category: $0.category, message: $0.composedMessage)}
                .sorted(by: {$0.date > $1.date})
        } catch {
            Logger.viewCycle.error("Failed to load logs: \(error.localizedDescription)")
            self.entries = []
        }
        self.loading = false
    }
}

struct LogEntry : Identifiable {
    let id = UUID()
    let date: Date
    let category: String
    let message: String
}
