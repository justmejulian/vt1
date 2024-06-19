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
    
    var body: some View {
        
        if entries.isEmpty {
            Text("No Logs")
        } else {
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
            }.onAppear(){
                do {
                    let store = try OSLogStore(scope: .currentProcessIdentifier)
                    let position = store.position(timeIntervalSinceLatestBoot: 1)
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
            }
            //todo make refreshanle
//            .refreshable {
//                <#code#>
//            }
        }
    }
}

struct LogEntry : Identifiable {
    let id = UUID()
    let date: Date
    let category: String
    let message: String
}
