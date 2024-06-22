//
//  Created by Julian Visser on 06.11.2023.
//

import SwiftUI
import SwiftData
import OSLog
import Foundation

struct RecordingDetailView: View {
    private let db: Database
    
    var recording: Recording
    
    @State var sensorDataCount: Int
    
    @State private var text: String
    @State private var exporting: Bool = false
    
    @State private var fileName: String
    
    @State private var document: File?
    
    @State private var loading = false
    
    init(recording: Recording, db: Database) {
        // todo check when this is initialized
        Logger.viewCycle.debug("Running init for RecordingDetailView: \(recording.startTimestamp)")
        self.recording = recording
        self.db = db
        
        self._text = State(initialValue: recording.exercise)
        self.sensorDataCount = 0
        self.fileName = ""
    }
    
    var body: some View {
        VStack{
            Spacer()
            Text("Recording: ")
                .font(.title)
                .bold()
            
            TextField("Exercise:", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.center)
                .padding(.all)
            
            Text(recording.startTimestamp.ISO8601Format())
                .font(.title3)
            Spacer()
            
            Text("# batches: " + String(sensorDataCount))
                .font(.title2)
            
            Spacer()
            
            Button(action: {
                updateData()
            }) {
                Label("Save", systemImage: "square.and.arrow.down")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            
            Button(action: {
                exporting = true
            }){
                Label("Export", systemImage: "square.and.arrow.up")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .fileExporter(
                isPresented: $exporting,
                document: document,
                contentType: .json,
                defaultFilename: fileName
            ){ result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            Button(action: {
                deleteData()
            }) {
                Label("Delete", systemImage: "trash")
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .task {
            self.loading = true
            let fileName = "Recording-\(recording.startTimestamp)"
            self.fileName = fileName
            Task {
                let modelContainer = db.getModelContainer()
                
                let sensorBatchBackgroundDataHandler = SensorBatchBackgroundDataHandler(modelContainer: modelContainer)
                let sensorBatches: [SensorBatchStruct] = await sensorBatchBackgroundDataHandler.fetchSendableData(for: recording.startTimestamp)
                self.sensorDataCount = sensorBatches.count
                
                let dict: RecordingDictionary = RecordingDictionary(recording: recording, sensorBatches: sensorBatches)
                
                do{
                    self.document = try await FileCreator().generateJson(fileName: fileName, data: dict)
                } catch {
                    Logger.viewCycle.error("Failed to generate Json \(error.localizedDescription)")
                }
                
                self.loading = false
            }
        }
    }
    
    func updateData() {
        Logger.viewCycle.info("updateData from RecordingDetailView new text: \(text)")
        recording.exercise = text
    }
    
    func deleteData() {
        Logger.viewCycle.info("deleteData from RecordingDetailView")
        db.removeData(recording)
    }
    
}

struct RecordingDictionary: Encodable {
    var exercise: String
    var startTimestamp: TimeInterval
    var sensorBatches: [SensorBatchStruct]
    
    init(recording: Recording, sensorBatches: [SensorBatchStruct]) {
        self.exercise = recording.exercise
        self.startTimestamp = recording.startTimestamp.timeIntervalSince1970
        self.sensorBatches = sensorBatches
    }
}

struct RecordingExportError: LocalizedError {
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
    
    var errorDescription: String? {
        description
    }
}

// todo move to background or add loading state

