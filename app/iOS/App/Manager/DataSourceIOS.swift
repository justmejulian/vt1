//
//  DataSourceIOS.swift
//  vt1 Mobile App
//
//  Created by Julian Visser on 17.04.2024.
//

import Foundation
import SwiftData
import OSLog

extension DataSource {
    
    @MainActor
    convenience init() {
        do {
            let modelContainer = try ModelContainer(for: RecordingData.self, SensorData.self, SyncData.self)
            let modelContext = modelContainer.mainContext
            
            self.init(modelContainer: modelContainer,modelContext: modelContext)
            
        } catch {
            Logger.statistics.error("Fatal Error creating IOS DataSource \(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
        
        // Delete all
        // self.clear()
    }
    
    
    func appendSyncData(_ syncData: SyncData) {
        appendData(syncData)
    }

    func fetchSyncData() -> [SyncData] {
        fetchData()
    }
}
