//
//  ConnectivityManagerWatchOS.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 26.11.2023.
//

import Foundation
import SwiftUI
import WatchConnectivity

extension ConnectivityManager {
    func session(_ session: WCSession, didReceiveMessage data: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {

        let sessionManager = SessionManager.shared
        
        if let exerciseName = data["startSession"] {
            print("recived start session with exerciseName:", exerciseName)
            
            if let exerciseName = exerciseName as? String {
                Task {
                    await sessionManager.start(exerciseName: exerciseName)
                    replyHandler(["sucess": true])
                }
                return
            }
            
            print("Failed to convert exerciseName to string", exerciseName)
            
            replyHandler(["error": "Failed to convert exerciseName to string"])
        }
        
        if (data["stopSession"] != nil) {
            print("recived stop session")

            sessionManager.stop()
            replyHandler(["sucess": true])
        }

        if (data["getSessionState"] != nil) {
            print("received get session state")
            replyHandler(["isSessionRunning": sessionManager.started])
            return
        }

        replyHandler(["error in Watch ConnectivityManager": "unknown data type"])
    }
    
    
    func sendSensorData(sensorData: SensorData, replyHandler: (([String : Any]) -> Void)?) {
        self.sendPresistentModel(key: "sensorData", data: sensorData, replyHandler: replyHandler)
    }

    func sendRecording(recording: RecordingData, replyHandler: (([String : Any]) -> Void)?) {
        self.sendPresistentModel(key: "recording", data: recording, replyHandler: replyHandler)
    }

    func sendSessionState(isSessionRunning: Bool) {
        let context = ["isSessionRunning": isSessionRunning]
        self.session.sendMessage(context, replyHandler: { replyData in
            print("sucessfully sent session state")
        }, errorHandler: { (error) in
            print("error sending", context, error.localizedDescription)
        })
    }
}
