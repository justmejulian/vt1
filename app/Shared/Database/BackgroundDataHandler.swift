//
//  Untitled.swift
//  vt1
//
//  Created by Julian Visser on 15.06.2024.
//

import Foundation
import SwiftData
import OSLog
import Throttler

// todo make this private
@ModelActor
actor BackgroundDataHandler {
    var lastUpdate: Date? = nil
}

extension BackgroundDataHandler {
    private func createModelContext(modelContainer: ModelContainer) -> ModelContext {
        Logger.viewCycle.debug("createModelContext on Thread \(Thread.current) is MainThread \(Thread.isMainThread)")
        let modelContext = ModelContext(modelContainer)
        modelContext.autosaveEnabled = false
        return modelContext
    }
    
    func save(modelContext: ModelContext) throws {
        Logger.viewCycle.debug("Saving Data on Thread \(Thread.current) is MainThread \(Thread.isMainThread)")
        lastUpdate = Date.now
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
    
    // todo split into save and no save
    func appendData<T>(_ data: T) where T : PersistentModel{
        Logger.viewCycle.debug("Appending Data: \(T.self), on Thread \(Thread.current) is MainThread \(Thread.isMainThread)")
        let modelContext = createModelContext(modelContainer: modelContainer)
        modelContext.insert(data)
        do {
            try save(modelContext: modelContext)
        } catch {
            Logger.viewCycle.error("Failed to save from append \(error.localizedDescription)")
        }
    }
    
    func appendData<T>(_ dataArray: [T]) where T : PersistentModel{
        Logger.viewCycle.debug("Appending Data Array: \(T.self), on Thread \(Thread.current) is MainThread \(Thread.isMainThread)")
        let modelContext = createModelContext(modelContainer: modelContainer)
        for data in dataArray {
            modelContext.insert(data)
        }
        do {
            try save(modelContext: modelContext)
        } catch {
            Logger.viewCycle.error("Failed to save from append \(error.localizedDescription)")
        }
    }

    func removeData(identifier: PersistentIdentifier) {
        Logger.viewCycle.debug("Removing Data: \(identifier.entityName), on Thread \(Thread.current)")
        let modelContext = createModelContext(modelContainer: modelContainer)
        let model = modelContext.model(for: identifier)
        modelContext.delete(model)
        do {
            try save(modelContext: modelContext)
        } catch {
            Logger.viewCycle.error("Failed to save from append \(error.localizedDescription)")
        }
    }
    
    func fetchData<T>() -> [T] where T : PersistentModel {
        return fetchData(descriptor: FetchDescriptor<T>())
    }
    
    func fetchData<T>(descriptor: FetchDescriptor<T>) -> [T] where T : PersistentModel {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            Logger.statistics.error("Failed to fetch \(T.self)")
            return []
        }
    }
    
    func fetchDataCount<T: PersistentModel>(for _: T.Type) -> Int {
        do {
            let descriptor = FetchDescriptor<T>()
            return try modelContext.fetchCount(descriptor)
        } catch {
            Logger.statistics.error("Failed to fetch count \(T.self)")
            return 0
        }
    }
    
    func fetchPersistentIdentifiers<T>(for _: T.Type) -> [PersistentIdentifier] where T : PersistentModel {
        do {
            return try self.modelContext.fetchIdentifiers(FetchDescriptor<T>())
        } catch {
            Logger.statistics.error("Failed to fetch Identifiers for \(T.self)")
            return []
        }
    }
    
}
