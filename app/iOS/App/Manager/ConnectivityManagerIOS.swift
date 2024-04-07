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
            if replyData["sucess"] != nil {
                Logger.viewCycle.debug("sucessfully sent getSessionState")
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
            Logger.viewCycle.error("error sending getSessionState: \(error.localizedDescription)")
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
