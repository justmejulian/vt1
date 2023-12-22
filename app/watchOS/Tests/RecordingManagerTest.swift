//
//  Created by Julian Visser on 21.12.2023.
//

import XCTest
@testable import vt1_Watch_App

final class RecordingManagerTest: XCTestCase {
    var recordingManager: RecordingManager!

    override func setUp() {
        super.setUp()
        recordingManager = RecordingManager()
    }

    override func tearDown() {
        recordingManager = nil
        super.tearDown()
    }

    func testStart() {
        let exercise = "Test Exercise"
        XCTAssertNoThrow(try recordingManager.start(exercise: exercise))
        XCTAssertTrue(recordingManager.isRecording)
    }

    func testStartWhenAlreadyRecording() {
        let exercise = "Test Exercise"
        XCTAssertNoThrow(try recordingManager.start(exercise: exercise))
        XCTAssertThrowsError(try recordingManager.start(exercise: exercise)) { error in
            XCTAssertEqual(error.localizedDescription, RecordingError("Recording already running").localizedDescription)
        }
    }

    func testStop() {
        let exercise = "Test Exercise"
        XCTAssertNoThrow(try recordingManager.start(exercise: exercise))
        recordingManager.stop()
        XCTAssertFalse(recordingManager.isRecording)
    }
}
