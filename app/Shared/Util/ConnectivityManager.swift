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
        let context: [String: Any] = ["test": "test"]
        session.sendMessage(context, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }

    func sendRecordings(recordings: [RecordingData])  {
        print("sending message")
        recordings.forEach{ recording in
            let data = try! JSONEncoder().encode(recording)

            self.session.sendMessageData(data, replyHandler: { replyData in
                print("reply", replyData)
                // todo set these as synced
            }, errorHandler: { (error) in
                print("error sending message", error.localizedDescription)
            })
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("calling did receivie message")
        if let message = message["test"] {
            print(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData data: Data, replyHandler: @escaping (Data) -> Void) {
        print("calling did receivie message")
        let recording = try! JSONDecoder().decode(RecordingData.self, from: data)

        print(recording.exercise)
        // self.dataSource.clear()
        self.dataSource.appendRecoring(recording: recording)
        
        print("sending reply")
        replyHandler(data)
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
}
