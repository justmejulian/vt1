//
//  ConnectivityManagerIOS.swift
//  vt1 Mobile App
//
//  Created by Julian Visser on 26.11.2023.
//

import Foundation
import WatchConnectivity

extension ConnectivityManager {
    
    func getSessionState() {
        let context = ["getSessionState": true]
        self.session.sendMessage(context, replyHandler: { replyData in
            if let isSessionRunning = replyData["isSessionRunning"] as? Bool {
                print("Got Session state", isSessionRunning)
                SessionManager.shared.isSessionRunning = isSessionRunning
                return
            }
            print("Something went wrong getSessionState")
            if let error = replyData["error"] {
                print(error)
                return
            }
        }, errorHandler: { (error) in
            print("error getting session state", error.localizedDescription)
            DispatchQueue.main.async {
                SessionManager.shared.isSessionRunning = false
            }
        })
    }
    
    func sendStartSession(exerciseName: String) {
        print("send StartSession")
        let context = ["startSession": exerciseName]
        self.session.sendMessage(context, replyHandler: { replyData in
            if replyData["sucess"] != nil {
                print("sucessfully started session")
                return
            }
            print("Something went wrong starting session")
            if let error = replyData["error"] {
                print(error)
                return
            }
        }, errorHandler: { (error) in
            print("error sending start session", exerciseName, error.localizedDescription)
        })
    }
    
    func sendStopSession() {
        print("send StopSession")
        let context = ["stopSession": true]
        self.session.sendMessage(context, replyHandler: { replyData in
            if replyData["sucess"] != nil {
                print("sucessfully started session")
                return
            }
            print("Something went wrong stopping session")
            if let error = replyData["error"] {
                print(error)
                return
            }
        }, errorHandler: { (error) in
            print("error sending stop session", error.localizedDescription)
        })
    }
    
    func session(_ session: WCSession, didReceiveMessage data: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {

        // print("recived data:", data)

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

        if let isSessionRunning = data["isSessionRunning"] as? Bool{
            print("recived isSessionRunning:", isSessionRunning)
            DispatchQueue.main.async {
                SessionManager.shared.isSessionRunning = isSessionRunning
            }
            replyHandler(["sucess": true])
            return
        }

        replyHandler(["error in iOS ConnectivityManager": "unknown data type"])
    }
    
    func sessionWatchStateDidChange(_ session: WCSession){
        print("Session WatchState Did Change")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session Did Become Inactive")
    }
    func sessionDidDeactivate(_ session: WCSession) {
        print("Session Did Become Deactivate")
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

