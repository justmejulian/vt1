//
//  Created by Julian Visser on 21.12.2023.
//

import XCTest
@testable import vt1_Watch_App
import WatchConnectivity

final class ConnectivityManagerTests: XCTestCase {
}
class MockSession: WCSession {
    // need to mock .default

    var fail = false

    override func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)?) {
        if fail {
            errorHandler?(NSError(domain: "Test", code: 1, userInfo: [:]))
        } else {
            replyHandler?(["response": "Success"])
        }
    }
}

class MockSessionManager: SessionManager {
    var startedExerciseName: String?
    var stopped = false

    override func start(exerciseName: String) async {
        startedExerciseName = exerciseName
    }

    override func stop() {
        stopped = true
    }
}


