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
    func sendSensorBatch(sensorBatch: SensorBatchStruct, replyHandler: (([String : Any]) -> Void)?) {
        self.sendCodable(key: "sensorBatch", data: sensorBatch, replyHandler: replyHandler)
    }

    func sendRecording(recording: RecordingStruct, replyHandler: (([String : Any]) -> Void)?) {
        self.sendCodable(key: "recording", data: recording, replyHandler: replyHandler)
    }

    func sendSessionState(isSessionRunning: Bool) {
        let context = ["isSessionRunning": isSessionRunning]
        self.session.sendMessage(context, replyHandler: { replyData in
            Logger.viewCycle.debug("sucessfully sent session state: isSessionRunning \(isSessionRunning)")
        }, errorHandler: { (error) in
            Logger.viewCycle.error("error sending \(context) \(error.localizedDescription)")
        })
    }
    
    func sendSessionReadyToStart(retryCount: Int = 3) {
        Logger.viewCycle.debug("sendSessionReadyToStart from ConnectivityManager")
        let context = ["isSessionReady": true]
        
        if (self.session.isReachable) {
            self.session.sendMessage(context, replyHandler: { replyData in
                Logger.viewCycle.debug("sucessfully sent session ready to Start.")
            }, errorHandler: { (error) in
                Logger.viewCycle.error("error sending \(context) \(error.localizedDescription)")
            })
        } else {
            Logger.viewCycle.debug("iPhone is not reachable yet.")
            // Wait 1s and then retry
            if retryCount > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    Logger.viewCycle.debug("Retrying to sendSessionReadyToStart \(retryCount)")
                    self.sendSessionReadyToStart(retryCount: retryCount - 1)
                }
            } else {
                Logger.viewCycle.debug("Not retrying to sendSessionReadyToStart \(retryCount)")
            }
        }
    }
}
