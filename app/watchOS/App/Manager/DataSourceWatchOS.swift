//
//  DataSourceWatchOS.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 17.04.2024.
//

import Foundation
import SwiftData
import OSLog

extension DataSource {
    
    @MainActor
    convenience init() {
        Logger.statistics.debug("Creating DataSource")
        do {
            let modelContainer = try ModelContainer(for: RecordingData.self, SensorData.self)
            let modelContext = modelContainer.mainContext
            
            self.init(modelContainer: modelContainer,modelContext: modelContext)
            
        } catch {
            Logger.statistics.error("Fatal Error creating watchOS DataSource \(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
        
        // Delete all
        // self.clear()
    }
}
