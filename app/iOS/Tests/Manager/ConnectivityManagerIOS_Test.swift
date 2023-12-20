import XCTest
@testable import vt1

class ConnectivityManagerTests: XCTestCase {
    var connectivityManager: ConnectivityManager!
    var mockSession: MockWCSession!

    override func setUp() {
        super.setUp()
        mockSession = MockWCSession()
        connectivityManager = ConnectivityManager(session: mockSession)
    }

    func testGetSessionStateRunning() {
        mockSession.replyHandlerData = ["isSessionRunning": true]
        connectivityManager.getSessionState()
        XCTAssertTrue(SessionManager.shared.isSessionRunning)
    }

    func testGetSessionStateNotRunning() {
        mockSession.replyHandlerData = ["isSessionRunning": false]
        connectivityManager.getSessionState()
        XCTAssertFalse(SessionManager.shared.isSessionRunning)
    }

    func testGetSessionStateError() {
        mockSession.shouldReturnError = true
        connectivityManager.getSessionState()
        XCTAssertFalse(SessionManager.shared.isSessionRunning)
    }
}

class MockWCSession: WCSession {
    var replyHandlerData: [String: Any]?
    var shouldReturnError = false

    override func sendMessage(_ message: [String : Any], replyHandler: (([String : Any]) -> Void)?, errorHandler: ((Error) -> Void)?) {
        if shouldReturnError {
            errorHandler?(NSError(domain: "", code: 0, userInfo: nil))
        } else {
            replyHandler?(replyHandlerData ?? [:])
        }
    }
}