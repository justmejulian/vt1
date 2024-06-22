//
//  vt1
//
//  Created by Julian Visser on 22.06.2024.
//

import SwiftData
import Foundation

actor RecordingBackgroundDataHandler {
    let backgroundDataHandler: BackgroundDataHandler
    
    init(modelContainer: ModelContainer) {
        self.backgroundDataHandler = BackgroundDataHandler(modelContainer: modelContainer)
    }
    
    func appendData(_ recordingStruct: RecordingStruct) async -> PersistentIdentifier {
        let recording = Recording(recordingStruct: recordingStruct)
        await backgroundDataHandler.appendData(recording)
        return recording.persistentModelID
    }
    
    func fetchSendableData() async -> [RecordingStruct] {
        let recordings: [Recording] = await backgroundDataHandler.fetchData()
        return recordings.map { RecordingStruct(recording: $0)}
    }
}
