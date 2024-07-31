//
//  Created by Julian Visser on 20.12.2023.
//

import Foundation
import SwiftUI
import OSLog

@MainActor
class SyncViewModel: ObservableObject {
    var sessionManager:SessionManager

    @Published var syncing = false

    init(sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    func sync() {
        Logger.viewCycle.info("Starting sync from SyncViewModel")
        syncing = true
        // todo actually wait for this so that syncing means something
        sessionManager.sync()
        syncing = false
        Logger.viewCycle.debug("Finished sync from SyncViewModel")
    }
}
