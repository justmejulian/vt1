//
//  ConnectivityManagerWatchOS.swift
//  vt1 Watch App
//
//  Created by Julian Visser on 26.11.2023.
//

import Foundation
import SwiftUI
import WatchConnectivity
import OSLog

extension ConnectivityManager {
    func session(_ session: WCSession, didReceiveMessage data: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {

        let sessionManager = SessionManager.shared
        
        if let exerciseName = data["startSession"] {
            Logger.viewCycle.info("recived start session")
            
            if let exerciseName = exerciseName as? String {
                Logger.viewCycle.info("start session with exerciseName: \(exerciseName)")
                Task {
                    await sessionManager.start(exerciseName: exerciseName)
                    replyHandler(["sucess": true])
                }
                return
            }
            
            Logger.viewCycle.error("Failed to convert exerciseName to string")
            
            replyHandler(["error": "Failed to convert exerciseName to string"])
        }
        
        if (data["stopSession"] != nil) {
            Logger.viewCycle.info("recived stop session")
            DispatchQueue.main.async {
                sessionManager.stop()
            }
            replyHandler(["sucess": true])
        }

        if (data["getSessionState"] != nil) {
            Logger.viewCycle.debug("received get session state")
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
            Logger.viewCycle.debug("sucessfully sent session state: isSessionRunning \(isSessionRunning)")
        }, errorHandler: { (error) in
            Logger.viewCycle.error("error sending \(context) \(error.localizedDescription)")
        })
    }
    
    func sendSessionReadyToStart() {
        Logger.viewCycle.debug("sendSessionReadyToStart from ConnectivityManager")
        let context = ["isSessionReady": true]
        self.session.sendMessage(context, replyHandler: { replyData in
            Logger.viewCycle.debug("sucessfully sent session ready to Start.")
        }, errorHandler: { (error) in
            Logger.viewCycle.error("error sending \(context) \(error.localizedDescription)")
        })
    }
}
