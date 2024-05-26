//
//  Created by Julian Visser on 20.12.2023.
//

import Foundation
import OSLog
import SwiftUI

class SyncViewModel: ObservableObject {
    private let dataSource: DataSource
    
    @Published
    var syncData: SyncData
    
    @Published
    var openPostRequests: Int = 0
    
    @Published
    var syncing: Bool = false
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
        do {
            let fetchedSyncDataArray = dataSource.fetchSyncData()
            if !fetchedSyncDataArray.isEmpty {
                let fetchedSyncData = fetchedSyncDataArray[0]
                self.syncData = fetchedSyncData
            } else {
                let newSyncData = SyncData(ip: "")
                self.syncData = newSyncData
                dataSource.appendSyncData(newSyncData)
            }
        } catch {
            let newSyncData = SyncData(ip: "")
            self.syncData = newSyncData
            dataSource.appendSyncData(newSyncData)
        }
    }
    
    func setIp(_ ip: String) {
        Logger.viewCycle.debug("Stored IP changed. New ip \(ip)")
        self.syncData.ip = ip
    }
    
    func postData(ip: String){
        Logger.viewCycle.info("Calling postData from SyncViewModel")
        let recordingData = dataSource.fetchRecordingArray()
        let sensorData = dataSource.fetchSensorDataArray(timestamp: nil)
        
        Logger.statistics.info("postData: recordingData \(recordingData.count), sensorData \(sensorData.count)")
        
        DispatchQueue.main.async {
            self.syncing = true
            self.openPostRequests = 0
        }
        
        let networkManager = NetworkViewModel(ip: ip)

        // todo add array of errors that occured
        for recording in recordingData {
//            if (!syncing) {
//                break
//            }
            DispatchQueue.main.async {
                self.openPostRequests += 1
            }
            networkManager.postRecordingToAPI(recording, handleSuccess: {
                data in
                DispatchQueue.main.async {
                    self.openPostRequests -= 1
                }
                self.dataSource.removeData(recording)
            })
        }
        Logger.viewCycle.info("Finished posting recordingData from SyncViewModel")
        
        Logger.statistics.info("Started sync: \(Date.now)")
        Logger.statistics.info("SensorData count \(sensorData.count)")

        let chunkSize = 100
        Logger.statistics.info("Chunk size \(chunkSize)")

        let chunkedSensorData = sensorData.chunked(into: chunkSize)
            
        for chunk in chunkedSensorData {
            // if (!syncing) {
            //     break
            // }
            DispatchQueue.main.async {
                self.openPostRequests += 1
            }
            
            networkManager.postSensorDataArrayToAPI(chunk, handleSuccess: {
                data in
                DispatchQueue.main.async {
                    self.openPostRequests -= 1
                    if (self.openPostRequests == 0) {
                        Logger.statistics.info("Finished to sending all at: \(Date.now)")
                    }
                }
                
                 for sensor in chunk {
                     self.dataSource.removeData(sensor)
                 }
            })
        }

//        for sensor in sensorData {
//            DispatchQueue.main.async {
//                self.openPostRequests += 1
//            }
//            
//            print(sensor.values.count)
//            do{
//                print(sensor.sensor_id)
//                print(sensor.values.count)
//                let values = try JSONEncoder().encode(sensor.values)
//                print(values.count)
//            } catch {
//                print("that did not work")
//            }
//            
//            networkManager.postSensorDataToAPI(sensor, handleSuccess: {
//                // todo test time it takes to send
//                data in
//                DispatchQueue.main.async {
//                    self.openPostRequests -= 1
//                    if (self.openPostRequests == 0) {
//                        Logger.statistics.info("Finished to sending all at: \(Date.now)")
//                    }
//                }
//                self.dataSource.removeData(sensor)
//            })
//        }
    }
    
    func cancel() {
        DispatchQueue.main.async {
            self.syncing = false
        }
    }

}
