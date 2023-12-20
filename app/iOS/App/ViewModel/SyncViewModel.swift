//
//  Created by Julian Visser on 20.12.2023.
//

import Foundation

class SyncViewModel{
    @ObservationIgnored
    private let dataSource = DataSource.shared
    
    func postData(ip: String){
        let recordingData = dataSource.fetchRecordingArray()
        let sensorData = dataSource.fetchSensorDataArray(timestamp: nil)
        let networkManager = NetworkViewModel(ip: ip)
        Task{
            recordingData.forEach {recording in
                networkManager.postRecordingToAPI(recording, handleSuccess: { data in self.dataSource.removeData(recording)})
            }
        }
        Task{
            sensorData.forEach {sensor in
                networkManager.postSensorDataToAPI(sensor, handleSuccess: { data in self.dataSource.removeData(sensor)})
            }
        }
    }
    func deleteAll(){
        dataSource.clear()
    }
}
