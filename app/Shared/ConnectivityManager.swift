//
//  SessionDelegater.swift
//
//  Created by Julian Visser on 05.11.2023.
//

import Foundation

import Combine
import WatchConnectivity

class ConnectivityManager: NSObject, WCSessionDelegate {
    
    static let shared = ConnectivityManager()
    
    private var session: WCSession = .default

    override init() {
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
        session.sendMessage(context, replyHandler: { replyMessage in
            if let message = replyMessage["reply"] {
                print("reply", message)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("calling did receivie message")
        if let message = message["test"] {
            print(message)
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String: Any]) -> Void) {
        print("calling did receivie message")
        if let message = message["test"] {
            print(message)
            replyHandler(["reply": true])
        }
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
#endif
}
