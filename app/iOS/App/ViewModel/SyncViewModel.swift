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
    
    init(db: Database) {
        Logger.viewCycle.info("Init called in SyncViewModel")
        self.db = db
        do {
            let fetchedSyncDataArray: [SyncData] = try db.fetchData()
            if !fetchedSyncDataArray.isEmpty {
                let fetchedSyncData = fetchedSyncDataArray[0]
                self.syncData = fetchedSyncData
            } else {
                let newSyncData = SyncData(ip: "")
                self.syncData = newSyncData
                db.appendData(newSyncData)
            }
        } catch {
            let newSyncData = SyncData(ip: "")
            self.syncData = newSyncData
            db.appendData(newSyncData)
        }
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
        
        do {
            let recordingData: [Recording] = try db.fetchData()
            let sensorData: [SensorBatch] = try db.fetchData()
            
            Logger.statistics.info("postData: recordingData \(recordingData.count), sensorData \(sensorData.count)")
            
            // todo add array of errors that occured
            for recording in recordingData {
                // todo: cancel https://www.hackingwithswift.com/quick-start/concurrency/how-to-cancel-a-task
                //            if (!syncing) {
                //                break
                //            }
                self.openPostRequests += 1
                networkManager.postRecordingToAPI(recording, handleSuccess: {
                    data in
                    self.openPostRequests -= 1
                    self.db.removeData(recording)
                })
            }
            Logger.viewCycle.info("Finished posting recordingData from SyncViewModel")
            
            Logger.statistics.info("Started sync: \(Date.now)")
            Logger.statistics.info("SensorBatch count \(sensorData.count)")
            
            sendSensorBatchChunked(networkManager: networkManager, sensorDataArray: sensorData)
            //        sendSensorBatchOneByOne(networkManager: networkManager, sensorDataArray: sensorData)
        } catch {
            Logger.viewCycle.info("Failed to post data: \(error)")
        }
    }
    
    func sendSensorBatchChunked(networkManager: NetworkViewModel, sensorDataArray: [SensorBatch]){
        // todo: a test with 10 100 150 20
        let chunkSize = 100
        Logger.statistics.info("Chunk size \(chunkSize)")
        
        let chunkedSensorBatch = sensorDataArray.chunked(into: chunkSize)
        
        for chunk in chunkedSensorBatch {
            // if (!syncing) {
            //     break
            // }
            DispatchQueue.main.async {
                self.openPostRequests += 1
            }
            
            networkManager.postSensorBatchArrayToAPI(chunk, handleSuccess: {
                data in
                self.openPostRequests -= 1
                if (self.openPostRequests == 0) {
                    Logger.statistics.info("Finished to sending all at: \(Date.now)")
                }
                
                for sensor in chunk {
                    self.db.removeData(sensor)
                }
            })
        }
    }
    
    func sendSensorBatchOneByOne(networkManager: NetworkViewModel, sensorDataArray: [SensorBatch]){
        for sensor in sensorDataArray {
            self.openPostRequests += 1
            
            do{
                let values = try JSONEncoder().encode(sensor.values)
            } catch {
                Logger.viewCycle.error("Failed to create JSON in sendSensorBatchOneByOne")
            }
            
            networkManager.postSensorBatchToAPI(sensor, handleSuccess: {
                // todo test time it takes to send
                data in
                self.openPostRequests -= 1
                if (self.openPostRequests == 0) {
                    Logger.statistics.info("Finished to sending all at: \(Date.now)")
                }
                self.db.removeData(sensor)
            })
        }
    }
    
    func cancel() {
        self.syncing = false
    }
    
}
