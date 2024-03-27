//
//  vt1
//
//  Created by Julian Visser on 05.11.2023.
//

import Foundation
import SwiftUI
import SwiftData
import Combine
import WatchConnectivity
import OSLog

class ConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @MainActor
    static let shared = ConnectivityManager()

    internal var session: WCSession = .default

    @ObservationIgnored
    internal let dataSource: DataSource

    @MainActor
    init(dataSource: DataSource = DataSource.shared) {
        Logger.statistics.debug("Creating ConnectivityManager")
        self.dataSource = dataSource

        super.init()

        self.session.delegate = self
        self.session.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Logger.viewCycle.debug("Handling activationDidCompleteWith")
        if let error = error {
            Logger.viewCycle.error("Error trying to activate WCSession: \(error.localizedDescription)")
        } else {
            Logger.viewCycle.info("The session has completed activation.")
        }
    }

    func sendPresistentModel<T: PersistentModel>(key: String, data: T, replyHandler: (([String : Any]) -> Void)?) where T:Codable {
        do {
            let encodedData = try JSONEncoder().encode(data)

            let context = [key: encodedData]
            // do this async?
            self.session.sendMessage(context, replyHandler: replyHandler, errorHandler: { (error) in
                Logger.viewCycle.error("Error sending: \(key) \(error.localizedDescription)")
            })
        } catch {
            Logger.viewCycle.error("Error sending Presistent Model: \(error)")
        }
    }

}
