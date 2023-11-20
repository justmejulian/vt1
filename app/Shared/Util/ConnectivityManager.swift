//
//  SessionDelegater.swift
//
//  Created by Julian Visser on 05.11.2023.
//

import Foundation
import SwiftData
import Combine
import WatchConnectivity

class ConnectivityManager: NSObject, WCSessionDelegate {
    private var session: WCSession = .default
    @ObservationIgnored
    private let dataSource: DataSource

    @MainActor
    static let shared = ConnectivityManager()

    @MainActor
    init(dataSource: DataSource = DataSource.shared) {
        self.dataSource = dataSource

        super.init()

        self.session.delegate = self
        self.session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }

    // todo try application context. use to update swiftdata?
    func sendMessage() {
        print("sending message")
        let context: [String: Any] = ["message": "test"]
        session.sendMessage(context, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }

    func sendPresistentModel<T: PersistentModel>(key: String, data: T) where T:Codable {
        let encodedData = try! JSONEncoder().encode(data)

        let context = [key: encodedData]
        // do this aysnc?
        self.session.sendMessage(context, replyHandler: { replyData in
            if replyData["sucess"] != nil {
                // todo handle this better
                // print("remove synced data")
                self.dataSource.removeData(data)
                return
            }
            print("Something went wrong sending data")
            if let error = replyData["error"] {
                print(error)
                return
            }
        }, errorHandler: { (error) in
            print("error sending", key, error.localizedDescription)
        })
    }

    func sendSensorData(sensorData: SensorData) {
        self.sendPresistentModel(key: "sensorData", data: sensorData)
    }

    func sendRecording(recording: RecordingData) {
        self.sendPresistentModel(key: "recording", data: recording)
    }

    func sendStartSession(exerciseName: String) {
        let context = ["startSession": exerciseName]
        self.session.sendMessage(context, replyHandler: { replyData in
            if replyData["sucess"] != nil {
                print("sucessfully started session")
                return
            }
            print("Something went wrong sending data")
            if let error = replyData["error"] {
                print(error)
                return
            }
        }, errorHandler: { (error) in
            print("error sending start session", exerciseName, error.localizedDescription)
        })
    }

    func session(_ session: WCSession, didReceiveMessage data: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        // todo test what happens when send wrong thing with recoding key
        if let endcodedRecording = data["recording"] {
            guard let recording = try? JSONDecoder().decode(RecordingData.self, from: endcodedRecording as! Data) else {
                print("error decoding recording")
                replyHandler(["error": "error decoding recording"])
                return
            }
            self.dataSource.appendRecording(recording)
            replyHandler(["sucess": true])
            return
        }

        if let endcodedSensorData = data["sensorData"] {
            guard let sensorData = try? JSONDecoder().decode(SensorData.self, from: endcodedSensorData as! Data) else {
                print("error decoding sensorData")
                replyHandler(["error": "error decoding sensorData"])
                return
            }
            self.dataSource.appendSensorData(sensorData)
            replyHandler(["sucess": true])
            return
        }

        if let sessionData = data["startSession"] {
            print("sessionData", sessionData)
            replyHandler(["sucess": true])
            return
        }

        replyHandler(["error": "unknown data type"])
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
}
