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

@MainActor
final class Database {
    private let modelContainer: ModelContainer
    
    // Main Model Context
    private let modelContext: ModelContext
    
    
    // todo take shema and use to handle errors
    init(modelContainer: ModelContainer) {
        Logger.statistics.debug("Creating Database, on Thread \(Thread.current)")
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        self.modelContext.autosaveEnabled = true
    }
    
    func getModelContainer() -> ModelContainer {
        return self.modelContainer
    }
    
    // todo maybe remove these and only use the dataHnalder
    internal func appendData<T>(_ data: T) where T : PersistentModel{
        self.modelContext.insert(data)
    }
    
    internal func fetchData<T>() -> [T] where T : PersistentModel {
        return fetchData(descriptor: FetchDescriptor<T>())
    }
    
    internal func fetchData<T>(descriptor: FetchDescriptor<T>) -> [T] where T : PersistentModel {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            Logger.statistics.error("Failed to fetch \(T.self)")
            return []
        }
    }
    
    internal func fetchDataCount<T: PersistentModel>(for _: T.Type) -> Int {
        do {
            let descriptor = FetchDescriptor<T>()
            return try modelContext.fetchCount(descriptor)
        } catch {
            Logger.statistics.error("Failed to fetch count \(T.self)")
            return 0
        }
    }
    
    internal func removeData<T>(_ data: T) where T: PersistentModel {
        self.modelContext.delete(data)
    }
    
    internal func removeModel<T>(_ dataModel: T.Type) where T : PersistentModel {
        do {
            try self.modelContext.delete(model: dataModel)
        } catch {
            Logger.statistics.error("Failed to remove \(T.self)")
        }
    }
}
