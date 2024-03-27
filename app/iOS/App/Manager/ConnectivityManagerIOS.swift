//
//  ConnectivityManagerIOS.swift
//  vt1 Mobile App
//
//  Created by Julian Visser on 26.11.2023.
//

import Foundation
import WatchConnectivity
import OSLog

extension ConnectivityManager {
    
    func getSessionState() {
        Logger.viewCycle.debug("getSessionState from ConnectivityManager")
        let context = ["getSessionState": true]
        self.session.sendMessage(context, replyHandler: { replyData in
            if let isSessionRunning = replyData["isSessionRunning"] as? Bool {
                Logger.viewCycle.debug("Got Session state \(isSessionRunning)")
                DispatchQueue.main.async {
                    SessionManager.shared.isSessionRunning = isSessionRunning
                }
                return
            }
            
            if let error = replyData["error"] {
                if let errorString = error as? String {
                    Logger.viewCycle.error("Something went wrong getSessionState: \(errorString)")
                    return
                }
                
                Logger.viewCycle.error("Something went wrong getSessionState, error was not a string")
                return
            }
            Logger.viewCycle.error("Something went wrong getSessionState, could not decode the response")
        }, errorHandler: { (error) in
            Logger.viewCycle.error("error getting session state \(error.localizedDescription)")
            DispatchQueue.main.async {
                SessionManager.shared.isSessionRunning = false
            }
        })
    }
    
    func sendStartSession(exerciseName: String) {
        Logger.viewCycle.debug("sendStartSession from ConnectivityManager for \(exerciseName)")
        let context = ["startSession": exerciseName]
        self.session.sendMessage(context, replyHandler: { replyData in
            if replyData["sucess"] != nil {
                Logger.viewCycle.debug("sucessfully started session for \(exerciseName)")
                return
            }
            
            if let error = replyData["error"] {
                if let errorString = error as? String {
                    Logger.viewCycle.error("Something went wrong sendStartSession: \(errorString)")
                    return
                }
                
                Logger.viewCycle.error("Something went wrong sendStartSession, error was not a string")
                return
            }
            Logger.viewCycle.error("Something went wrong sendStartSession, could not decode the response")
        }, errorHandler: { (error) in
            Logger.viewCycle.error("error sending start session for exerciseName \(exerciseName): \(error.localizedDescription)")
        })
    }
    
    
    // todo add sucess / error handler
    // also abstract start and stop into 1 shared self.session.sendMessage
    // same as sendPresistentModel
    func sendStopSession() {
        Logger.viewCycle.debug("send StopSession from ConnectivityManager")
        let context = ["stopSession": true]
        self.session.sendMessage(context, replyHandler: { replyData in
            if replyData["sucess"] != nil {
                Logger.viewCycle.debug("sucessfully started session")
                return
            }
            
            if let error = replyData["error"] {
                if let errorString = error as? String {
                    Logger.viewCycle.error("Something went wrong sendStopSession: \(errorString)")
                    return
                }
                
                Logger.viewCycle.error("Something went wrong sendStopSession, error was not a string")
                return
            }
            Logger.viewCycle.error("Something went wrong sendStopSession, could not decode the response")
        }, errorHandler: { (error) in
            Logger.viewCycle.error("error sending stop session: \(error.localizedDescription)")
        })
    }
    
    func session(_ session: WCSession, didReceiveMessage data: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {

        if let endcodedRecording = data["recording"] {
            guard let recording = try? JSONDecoder().decode(RecordingData.self, from: endcodedRecording as! Data) else {
                Logger.viewCycle.debug("error decoding recording")
                replyHandler(["error": "error decoding recording"])
                return
            }

            self.dataSource.appendRecording(recording)
            replyHandler(["sucess": true])
            return
        }

        if let endcodedSensorData = data["sensorData"] {
            guard let sensorData = try? JSONDecoder().decode(SensorData.self, from: endcodedSensorData as! Data) else {
                Logger.viewCycle.error("error decoding sensorData")
                replyHandler(["error": "error decoding sensorData"])
                return
            }

            self.dataSource.appendSensorData(sensorData)
            replyHandler(["sucess": true])
            return
        }

        if let isSessionRunning = data["isSessionRunning"] as? Bool{
            Logger.viewCycle.debug("recived isSessionRunning: \(isSessionRunning)")
            DispatchQueue.main.async {
                SessionManager.shared.isSessionRunning = isSessionRunning
            }
            replyHandler(["sucess": true])
            return
        }
        
        if let isSessionReady = data["isSessionReady"] as? Bool{
            Logger.viewCycle.debug("recived isSessionReady: \(isSessionReady)")
            Task {
                await SessionManager.shared.startSession()
            }
            replyHandler(["sucess": true])
            return
        }

        replyHandler(["error in iOS ConnectivityManager": "unknown data type"])
    }
    
    func sessionWatchStateDidChange(_ session: WCSession){
        Logger.viewCycle.debug("Session WatchState Did Change")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        Logger.viewCycle.debug("Session Did Become Inactive")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        Logger.viewCycle.debug("Session Did Become Deactivate")
    }
}

struct ConnectivityError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}

