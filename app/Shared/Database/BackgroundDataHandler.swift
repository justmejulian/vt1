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
        let lastUpdateString: String = lastUpdate?.ISO8601Format() ?? ""
        Logger.viewCycle.debug("Saving Data on Thread \(Thread.current) is MainThread \(Thread.isMainThread)")
        // todo use this to throttle
        lastUpdate = Date.now
        try modelContext.save()
    }
    
    internal func appendData<T>(_ data: T) where T : PersistentModel{
        Logger.viewCycle.debug("Appending Data: \(T.self), on Thread \(Thread.current) is MainThread \(Thread.isMainThread)")
        let modelContext = createModelContext(modelContainer: modelContainer)
        modelContext.insert(data)
        // todo remove save
        do {
            try save(modelContext: modelContext)
        } catch {
            Logger.viewCycle.error("Failed to save from append \(error.localizedDescription)")
        }
    }
    
    // todo delete using Identifier
    internal func removeData<T>(_ data: T) where T: PersistentModel {
        Logger.viewCycle.debug("Appending Data: \(T.self), on Thread \(Thread.current)")
        Logger.viewCycle.debug("Removing Data: \(T.self)")
        let modelContext = createModelContext(modelContainer: modelContainer)
        modelContext.delete(data)
        // todo save
    }
}
