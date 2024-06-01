//
//  vt1
//
//  Created by Julian Visser on 06.11.2023.
//


// https://dev.to/jameson/swiftui-with-swiftdata-through-repository-36d1

import Foundation
import SwiftData
import OSLog
import Throttler

final class DataSource: ObservableObject {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer, modelContext: ModelContext) {
        Logger.statistics.debug("Creating DataSource")
        self.modelContainer = modelContainer
        self.modelContext = modelContext
        self.modelContext.autosaveEnabled = false
    }

    func getModelContainer() -> ModelContainer {
        return self.modelContainer
    }
    
    
    func getModelContext() -> ModelContext {
        return self.modelContext
    }
    
    @MainActor
    func save() throws {
        Logger.viewCycle.debug("Saving ...")
        try self.modelContext.save()
    }

    internal func appendData<T>(_ data: T) where T : PersistentModel{
        Logger.viewCycle.debug("Appending Data: \(T.self)")
        self.modelContext.insert(data)
        throtteledSave()
    }

    internal func fetchData<T>() -> [T] where T : PersistentModel {
        do {
            // todo does this need to be on main?
            return try modelContext.fetch(FetchDescriptor<T>())
        } catch {
            Logger.statistics.error("Fatal Error fetchData DataSource \(error.localizedDescription)")
            fatalError(error.localizedDescription)
        }
    }

    internal func removeData<T>(_ data: T) where T: PersistentModel {
        Logger.viewCycle.debug("Removing Data: \(T.self)")
        self.modelContext.delete(data)
        throtteledSave()
    }

    func appendSensorData(_ sensorData: SensorData) {
        appendData(sensorData)
    }

    func appendRecording(_ recording: RecordingData) {
        appendData(recording)
    }

    func fetchRecordingArray() -> [RecordingData] {
        fetchData()
    }

    func fetchSensorDataArray(timestamp: Date? = nil) -> [SensorData] {
        let data: [SensorData] = fetchData()
        guard timestamp != nil else {
            return data
        }

        return data.filter { $0.recordingStart == timestamp }
    }

    private func throtteledSave() {
        throttle(.seconds(10), option: .ensureLast) {
            Logger.viewCycle.debug("Running Throttled Save")
            DispatchQueue.main.async {
                do {
                    try self.save()
                } catch {
                    Logger.viewCycle.error("Failed to sace dataSource: \(error)")
                }
            }
        }
    }

    func clear() {
        Logger.viewCycle.info("Clearing all RecordingData and SensorData from DataSource.")
        do {
            try modelContext.delete(model: RecordingData.self)
            try modelContext.delete(model: SensorData.self)
        } catch {
            Logger.viewCycle.error("Failed to clear all all RecordingData and SensorData from DataSource.")
        }
    }
    
    func clear<T>(dataModel: T.Type) where T : PersistentModel {
        Logger.viewCycle.info("Clearing all data from \(T.self)")
        do {
            try modelContext.delete(model: T.self)
        } catch {
            Logger.viewCycle.error("Failed to clear all data from \(T.self).")
        }
    }
}
