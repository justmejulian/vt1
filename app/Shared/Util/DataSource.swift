//
//  DataSource.swift
//  vt1
//
//  Created by Julian Visser on 06.11.2023.
//


// https://dev.to/jameson/swiftui-with-swiftdata-through-repository-36d1

import Foundation
import SwiftData

final class DataSource {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    @MainActor
    static let shared = DataSource()

    @MainActor
    private init() {
        self.modelContainer = try! ModelContainer(for: RecordingData.self)
        self.modelContext = modelContainer.mainContext
    }

    func appendRecoring(recording: RecordingData) {
        modelContext.insert(recording)
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func fetchRecordings() -> [RecordingData] {
        do {
            return try modelContext.fetch(FetchDescriptor<RecordingData>())
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func removeRecording(_ recording: RecordingData) {
        modelContext.delete(recording)
    }
    
    func clear() {
        do {
            try modelContext.delete(model: RecordingData.self)
        } catch {
            print("Failed to clear all data.")
        }
    }
}
