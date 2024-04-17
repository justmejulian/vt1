//
//  vt1
//
//  Created by Julian Visser on 06.11.2023.
//


// https://dev.to/jameson/swiftui-with-swiftdata-through-repository-36d1

import Foundation
import SwiftData
import OSLog

final class DataSource {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer, modelContext: ModelContext) {
        Logger.statistics.debug("Creating DataSource")
        self.modelContainer = modelContainer
        self.modelContext = modelContext
    }

    func getModelContainer() -> ModelContainer {
        return self.modelContainer
    }

    internal func appendData<T>(_ data: T) where T : PersistentModel{
        DispatchQueue.main.async {
            self.modelContext.insert(data)
        }
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
        modelContext.delete(data)
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

    func clear() {
        Logger.viewCycle.info("Clearing all data from DataSource.")
        do {
            try modelContext.delete(model: RecordingData.self)
            try modelContext.delete(model: SensorData.self)
        } catch {
            Logger.viewCycle.error("Failed to clear all data from DataSource.")
        }
    }
}
