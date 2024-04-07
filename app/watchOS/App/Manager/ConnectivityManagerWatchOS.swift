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
