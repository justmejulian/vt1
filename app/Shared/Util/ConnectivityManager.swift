//
//  SessionDelegater.swift
//
//  Created by Julian Visser on 05.11.2023.
//

import Foundation
import SwiftUI
import SwiftData
import Combine
import WatchConnectivity

class ConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @MainActor
    static let shared = ConnectivityManager()

    internal var session: WCSession = .default

    @ObservationIgnored
    internal let dataSource: DataSource

    @MainActor
    init(dataSource: DataSource = DataSource.shared) {
        self.dataSource = dataSource

        super.init()

        self.session.delegate = self
        self.session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Handling activationDidCompleteWith")
        if let error = error {
            print("Error trying to activate WCSession: ",error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }

    func sendPresistentModel<T: PersistentModel>(key: String, data: T, replyHandler: (([String : Any]) -> Void)?) where T:Codable {
        do {
            let encodedData = try JSONEncoder().encode(data)

            let context = [key: encodedData]
            // do this async?
            self.session.sendMessage(context, replyHandler: replyHandler, errorHandler: { (error) in
                print("error sending", key, error.localizedDescription)
            })
        } catch {
            print("Error sending Presistent Model: ", error)
        }
    }

}
