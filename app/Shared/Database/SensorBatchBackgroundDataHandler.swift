//
//  vt1
//
//  Created by Julian Visser on 22.06.2024.
//

import SwiftData
import Foundation

actor SensorBatchBackgroundDataHandler {
    let backgroundDataHandler: BackgroundDataHandler
    
    init(modelContainer: ModelContainer) {
        self.backgroundDataHandler = BackgroundDataHandler(modelContainer: modelContainer)
    }
    
    func appendData(_ sensorBatchStruct: SensorBatchStruct) async -> PersistentIdentifier {
        let sensorBatch = SensorBatch(sensorBatchStruct: sensorBatchStruct)
        await backgroundDataHandler.appendData(sensorBatch)
        return sensorBatch.persistentModelID
    }
    
    func fetchSendableData() async -> [SensorBatchStruct] {
        let sensorBatches: [SensorBatch] = await backgroundDataHandler.fetchData()
        return sensorBatches.map { SensorBatchStruct(sensorBatch: $0)}
    }
    
    func fetchSendableData(for recordingStart: Date) async -> [SensorBatchStruct] {
        let descriptor = FetchDescriptor<SensorBatch>(
            predicate: #Predicate<SensorBatch> {
                $0.recordingStart == recordingStart
            }
        )
        let sensorBatches: [SensorBatch] = await backgroundDataHandler.fetchData(descriptor: descriptor)
        return sensorBatches.map { SensorBatchStruct(sensorBatch: $0)}
    }
}
