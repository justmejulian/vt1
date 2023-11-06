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
    // private var modelContainer: ModelContainer
    // private var modelContext: ModelContext

    static let shared = ConnectivityManager()
    
    private var session: WCSession = .default
    
    override init() {
        // self.modelContainer = try! SwiftData.ModelContainer(for: RecordingData.self)
        // self.modelContext = SwiftData.ModelContext(self.modelContainer)

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
        let data = try! JSONEncoder().encode(recordings)
        print(data)
        self.session.sendMessageData(data, replyHandler: { replyData in
            print("reply", replyData)
        }, errorHandler: { (error) in
            print("error sending message", error.localizedDescription)
        })
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("calling did receivie message")
        if let message = message["test"] {
            print(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessageData data: Data, replyHandler: @escaping (Data) -> Void) {
        print("calling did receivie message")
        print(data)
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
}
