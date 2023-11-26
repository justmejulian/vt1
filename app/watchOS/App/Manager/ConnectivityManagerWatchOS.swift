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

        replyHandler(["error": "unknown data type"])
    }
}
