//
//  ConnectivityManagerIOS.swift
//  vt1 Mobile App
//
//  Created by Julian Visser on 26.11.2023.
//

import Foundation
import WatchConnectivity

extension ConnectivityManager {
    
    func session(_ session: WCSession, didReceiveMessage data: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        // todo test what happens when send wrong thing with recoding key
        if let endcodedRecording = data["recording"] {
            guard let recording = try? JSONDecoder().decode(RecordingData.self, from: endcodedRecording as! Data) else {
                print("error decoding recording")
                replyHandler(["error": "error decoding recording"])
                return
            }
            
            // todo repace this with funcion params
            self.dataSource.appendRecording(recording)
            replyHandler(["sucess": true])
            return
        }

        if let endcodedSensorData = data["sensorData"] {
            // todo move this matching to enum sensorData -> SensorData.self
            guard let sensorData = try? JSONDecoder().decode(SensorData.self, from: endcodedSensorData as! Data) else {
                print("error decoding sensorData")
                replyHandler(["error": "error decoding sensorData"])
                return
            }
            self.dataSource.appendSensorData(sensorData)
            replyHandler(["sucess": true])
            return
        }

        replyHandler(["error": "unknown data type"])
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        isConnected = false
    }
    func sessionDidDeactivate(_ session: WCSession) {
        isConnected = false
    }
}
