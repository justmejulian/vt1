//
//  Created by Julian Visser on 20.12.2023.
//

import Foundation
import OSLog

class SyncViewModel{
    @ObservationIgnored
    private let dataSource = DataSource.shared
    
    func postData(ip: String){
        Logger.viewCycle.info("Calling postData from SyncViewModel")
        let recordingData = dataSource.fetchRecordingArray()
        let sensorData = dataSource.fetchSensorDataArray(timestamp: nil)
        
        Logger.statistics.info("postData: recordingData \(recordingData.count), sensorData \(sensorData)")
        
        let networkManager = NetworkViewModel(ip: ip)
        
        // todo do I need Task here?
        // todo add some syncing state
        Task{
            recordingData.forEach {recording in
                networkManager.postRecordingToAPI(recording, handleSuccess: { data in self.dataSource.removeData(recording)})
            }
            Logger.viewCycle.info("Finished posting recordingData from SyncViewModel")
        }
        Task{
            sensorData.forEach {sensor in
                networkManager.postSensorDataToAPI(sensor, handleSuccess: { data in self.dataSource.removeData(sensor)})
            }
            Logger.viewCycle.info("Finished posting sensorData from SyncViewModel")
        }

    }
    func deleteAll(){
        Logger.viewCycle.info("Calling dataSource.clear from SyncViewModel")
        dataSource.clear()
    }
}
