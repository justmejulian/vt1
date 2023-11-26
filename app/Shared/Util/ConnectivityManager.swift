//
//  SessionDelegater.swift
//
//  Created by Julian Visser on 05.11.2023.
//

// todo clean up imports
import Foundation
import SwiftUI
import SwiftData
import Combine
import WatchConnectivity

class ConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @MainActor
    static let shared = ConnectivityManager()

    private var session: WCSession = .default
    
    @ObservationIgnored
    internal let dataSource: DataSource
    
    @Published
    var isConnected = false

    @MainActor
    init(dataSource: DataSource = DataSource.shared) {
        self.dataSource = dataSource

        super.init()

        self.session.delegate = self
        self.session.activate()
        isConnected = true
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

    func sendPresistentModel<T: PersistentModel>(key: String, data: T, replyHandler: (([String : Any]) -> Void)?) where T:Codable {
        let encodedData = try! JSONEncoder().encode(data)

        let context = [key: encodedData]
        // do this aysnc?
        self.session.sendMessage(context, replyHandler: replyHandler, errorHandler: { (error) in
            print("error sending", key, error.localizedDescription)
        })
    }

    func sendSensorData(sensorData: SensorData, replyHandler: (([String : Any]) -> Void)?) {
        self.sendPresistentModel(key: "sensorData", data: sensorData, replyHandler: replyHandler)
    }

    func sendRecording(recording: RecordingData, replyHandler: (([String : Any]) -> Void)?) {
        self.sendPresistentModel(key: "recording", data: recording, replyHandler: replyHandler)
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
}
