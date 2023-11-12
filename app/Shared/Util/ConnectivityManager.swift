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

    func send<T: PersistentModel>(key: String, data: T) where T:Codable {
        let encodedData = try! JSONEncoder().encode(data)

        let context = [key: encodedData]
        print(context)
        // do this aysnc?
        self.session.sendMessage(context, replyHandler: { replyData in
            if replyData["sucess"] != nil {
                // todo handle this better
                self.dataSource.addSynced(data)
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
        self.send(key: "sensorData", data: sensorData)
    }

    func sendRecording(recording: RecordingData) {
        self.send(key: "recording", data: recording)
    }

    func session(_ session: WCSession, didReceiveMessage data: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("calling did receivie message", data)
        // todo test what happens when send wrong thing with recoding key
        if let endcodedRecording = data["recording"] {
            guard let recording = try? JSONDecoder().decode(RecordingData.self, from: endcodedRecording as! Data) else {
                print("error decoding recording")
                replyHandler(["error": "error decoding recording"])
                return
            }
            print("recived recording", recording)
            self.dataSource.appendRecoring(recording)
            replyHandler(["sucess": true])
        }

        if let endcodedSensorData = data["sensorData"] {
            guard let sensorData = try? JSONDecoder().decode(SensorData.self, from: endcodedSensorData as! Data) else {
                print("error decoding sensorData")
                replyHandler(["error": "error decoding sensorData"])
                return
            }
            print("recived sensorData", sensorData)
            self.dataSource.appendSensorData(sensorData)
            replyHandler(["sucess": true])
        }

        replyHandler(["error": "unknown data type"])
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
}
