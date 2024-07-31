//
//  Created by Julian Visser on 20.12.2023.
//

import Foundation
import OSLog
import SwiftUI

@MainActor
class SyncViewModel: ObservableObject {
    private let db: Database
    
    @Published
    var syncData: SyncData
    
    @Published
    var openPostRequests: Int = 0
    
    @Published
    var syncing: Bool = false
    
    @Published
    var hasError: Bool = false
    @Published
    var errorMessage: String = ""
    
    @Published var sensorBatchCount: Int = 0
    @Published var recordingCount: Int = 0
    
    init(db: Database) {
        Logger.viewCycle.info("Init called in SyncViewModel")
        self.db = db
        
        let fetchedSyncDataArray: [SyncData] = db.fetchData()
        if !fetchedSyncDataArray.isEmpty {
            let fetchedSyncData = fetchedSyncDataArray[0]
            self.syncData = fetchedSyncData
        } else {
            let newSyncData = SyncData(ip: "")
            self.syncData = newSyncData
            db.appendData(newSyncData)
        }
    }
    
    func fetchCount(){
        self.sensorBatchCount = db.fetchDataCount(for: SensorBatch.self)
        self.recordingCount = db.fetchDataCount(for: Recording.self)
    }
    
    func setIp(_ ip: String) {
        Logger.viewCycle.debug("Stored IP changed. New ip \(ip)")
        self.syncData.ip = ip
    }
    
    func postData(ip: String) async{
        Logger.viewCycle.info("Calling postData from SyncViewModel")
        
        self.syncing = true
        self.openPostRequests = 0
        self.hasError = false
        self.errorMessage = ""
        Logger.viewCycle.info("Setting vars in SyncViewModel syncing: \(self.syncing)")
        // todo add count for synced and failed
        
        let networkManager = NetworkViewModel(ip: ip)
        
        // todo test if server is available
        let isRunning = await networkManager.getStatus()
        
        Logger.viewCycle.info("SyncViewModel getStatus: \(isRunning)")
        
        if (!isRunning) {
            self.syncing = false
            self.openPostRequests = 0
            self.hasError = true
            self.errorMessage = "Could not reach server \(ip)"
            
            // Exit function
            return
        }
        
        Logger.viewCycle.info("SyncViewModel start sycning")
        
        self.postRecordings(networkManager: networkManager)
        self.postSensorBachtes(networkManager: networkManager)
        
        Logger.viewCycle.info("SyncViewModel finished sycning")
    }
    
    func postRecordings(networkManager: NetworkViewModel) {
        let modelContainer = self.db.getModelContainer()
        // todo maybe detach
        Task.detached {
            let recordingBackgroundDataHandler = RecordingBackgroundDataHandler(modelContainer: modelContainer)
            let recordings: [RecordingStruct] = await recordingBackgroundDataHandler.fetchSendableData()
            Logger.statistics.info("postData: recordingData \(recordings.count)")
            
            for recording in recordings {
                // todo: cancel https://www.hackingwithswift.com/quick-start/concurrency/how-to-cancel-a-task
                //            if (!syncing) {
                //                break
                //            }
                await self.increasePostRequests()
                await networkManager.postRecordingToAPI(recording, handleSuccess: {
                    data in
                    Task {
                        await self.decreasePostRequests()
                        await self.removeRecording(recording: recording)
                    }
                })
            }
            Logger.viewCycle.info("Finished posting recordingData from SyncViewModel")
        }
    }
    
    func postSensorBachtes(networkManager: NetworkViewModel) {
        Logger.statistics.info("Started SensorBatch sync: \(Date.now)")
        let modelContainer = self.db.getModelContainer()
        
        // todo maybe detach
        Task.detached {
            let sensorBatchBackgroundDataHandler = SensorBatchBackgroundDataHandler(modelContainer: modelContainer)
            let sensorBatch: [SensorBatchStruct] = await sensorBatchBackgroundDataHandler.fetchSendableData()
            Logger.statistics.info("postData: sensorBatch \(sensorBatch.count)")
            await self.sendSensorBatchChunked(networkManager: networkManager, sensorBatchArray: sensorBatch)
        }
        //        sendSensorBatchOneByOne(networkManager: networkManager, sensorBatchArray: sensorBatch)
    }
    
    func increasePostRequests() {
        self.openPostRequests += 1
    }
    
    func decreasePostRequests() {
        self.openPostRequests -= 1
    }
    
    func sendSensorBatchChunked(networkManager: NetworkViewModel, sensorBatchArray: [SensorBatchStruct]){
        // todo: a test with 10 100 150 20
        let chunkSize = 100
        Logger.statistics.info("Chunk size \(chunkSize)")
        
        let chunkedSensorBatch = sensorBatchArray.chunked(into: chunkSize)
        
        for chunk in chunkedSensorBatch {
            // if (!syncing) {
            //     break
            // }
            increasePostRequests()
            
            networkManager.postSensorBatchArrayToAPI(chunk, handleSuccess: {
                data in
                
                Task {
                    await self.decreasePostRequests()
                    if (await self.openPostRequests == 0) {
                        Logger.statistics.info("Finished to sending all at: \(Date.now)")
                    }
                    
                    for sensor in chunk {
                        // todo add remove chunk
                        await self.removeSensorBatch(sensorBatch: sensor)
                    }
                }
            })
        }
    }
    
    func sendSensorBatchOneByOne(networkManager: NetworkViewModel, sensorBatchArray: [SensorBatchStruct]){
        for sensor in sensorBatchArray {
            self.openPostRequests += 1
            
            networkManager.postSensorBatchToAPI(sensor, handleSuccess: {
                // todo test time it takes to send
                data in
                Task {
                    await self.decreasePostRequests()
                    if (await self.openPostRequests == 0) {
                        Logger.statistics.info("Finished to sending all at: \(Date.now)")
                    }
                    await self.removeSensorBatch(sensorBatch: sensor)
                }
            })
        }
    }
    
    
    func removeRecording(recording: RecordingStruct) async {
        let modelContainer = self.db.getModelContainer()
        let backgroundDataHandler = BackgroundDataHandler(modelContainer: modelContainer)
        guard let id = recording.id else {
            Logger.viewCycle.error("Failed to delete recording")
            return
        }
        await backgroundDataHandler.removeData(identifier: id)
        self.recordingCount -= 1
    }
    
    func removeSensorBatch(sensorBatch: SensorBatchStruct) {
        let modelContainer = self.db.getModelContainer()
        let backgroundDataHandler = BackgroundDataHandler(modelContainer: modelContainer)
        guard let id = sensorBatch.id else {
            Logger.viewCycle.error("Failed to delete sensorBatch")
            return
        }
        await backgroundDataHandler.removeData(identifier: id)
        
        self.sensorBatchCount -= 1
    }
    
    func cancel() {
        self.syncing = false
    }
    
}
