//
//  Created by Julian Visser on 20.12.2023.
//

import Foundation
import SwiftUI

class SyncViewModel: ObservableObject {
    @ObservedObject
    var sessionManager = SessionManager.shared
    
    @Published var syncing = false
    
    func sync() {
        syncing = true
        sessionManager.sync()
        syncing = false
    }
}
