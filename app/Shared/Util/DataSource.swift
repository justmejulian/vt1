//
//  Created by Julian Visser on 06.11.2023.
//


// https://dev.to/jameson/swiftui-with-swiftdata-through-repository-36d1

import Foundation
import SwiftData

enum DataTypes {
    case recording(RecordingData)
    case sensorData(SensorData)
}

final class DataSource {
    @MainActor
    static let shared = DataSource()

    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    private init() {
        do {
            self.modelContainer = try ModelContainer(for: RecordingData.self, SensorData.self)
            self.modelContext = modelContainer.mainContext
        } catch {
            fatalError(error.localizedDescription)
        }

        self.clear()
    }

    func getModelContainer() -> ModelContainer {
        return self.modelContainer
    }

    private func appendData<T>(_ data: T) where T : PersistentModel{
        DispatchQueue.main.async {
            self.modelContext.insert(data)
        }
    }

    private func fetchData<T>() -> [T] where T : PersistentModel {
        do {
            return try modelContext.fetch(FetchDescriptor<T>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func removeData<T>(_ data: T) where T: PersistentModel {
        modelContext.delete(data)
    }

    func appendSensorData(_ sensorData: SensorData) {
        // todo check if already exists
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
        print("Clearing all data.")
        do {
            try modelContext.delete(model: RecordingData.self)
            try modelContext.delete(model: SensorData.self)
        } catch {
            print("Failed to clear all data.")
        }
    }
}
