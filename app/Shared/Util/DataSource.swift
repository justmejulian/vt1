//
//  DataSource.swift
//  vt1
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
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    static let shared = DataSource()

    @MainActor
    private init() {
        do {
            self.modelContainer = try ModelContainer(for: RecordingData.self, SensorData.self, SyncedData.self)
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
        modelContext.insert(data)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    private func fetchData<T>() -> [T] where T : PersistentModel {
        do {
            return try modelContext.fetch(FetchDescriptor<T>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }

// func addSynced<T>(_ data: T) where T: PersistentModel {
//        if let sensorData = data as? SensorData {
//            self.syncedData.sensorData.append(sensorData)
//            // todo try and save?
//            return
//        }
//
//        if let recordingData = data as? RecordingData {
//            self.syncedData.recoridngs.append(recordingData)
//            // todo try and save?
//            return
//        }
//        print("Unkown data type in addSynced")
//    }

    func removeData<T>(_ data: T) where T: PersistentModel {
        modelContext.delete(data)
    }

    func appendSensorData(_ sensorData: SensorData) {
        print(sensorData.id, sensorData.recordingStart, sensorData.timestamp, sensorData.sensor_id, sensorData.x, sensorData.y, sensorData.z)
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
        print("clearing all data")
        do {
            try modelContext.delete(model: RecordingData.self)
        } catch {
            print("Failed to clear all data.")
        }
    }
}
