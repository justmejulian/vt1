//
//  Created by Julian Visser on 06.11.2023.
//

import SwiftUI
import SwiftData
import OSLog
import Foundation

struct RecordingDetailView: View {
    @ObservationIgnored
    private let dataSource: DataSource
    
    var recording: RecordingData

    @State var sensorDataCount: Int

    @State private var text: String
    @State private var exporting: Bool = false
    
    @State private var fileName: String
    
    @State private var document: File?
    
    init(recording: RecordingData, dataSource: DataSource) {
        // todo check when this is initialized
        Logger.viewCycle.debug("Running init for RecordingDetailView: \(recording.startTimestamp)")
        self.recording = recording
        self.dataSource = dataSource

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
                document = generateJson(dataSource: dataSource, recording: recording, fileName: fileName)
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
        .onAppear {
            Logger.viewCycle.info("RecordingDetailView Appeared!")
            let  modelContext = dataSource.getModelContext()

            
            let descriptor = FetchDescriptor<SensorData>(
                predicate: #Predicate<SensorData> {
                    $0.recordingStart == recording.startTimestamp
                }
            )
            self.sensorDataCount = (try? modelContext.fetchCount(descriptor)) ?? 0
            self.fileName = "Recording-\(recording.startTimestamp)"
        }
    }

    func updateData() {
        Logger.viewCycle.info("updateData from RecordingDetailView new text: \(text)")
        recording.exercise = text
    }

    func deleteData() {
        Logger.viewCycle.info("deleteData from RecordingDetailView")
        dataSource.removeData(recording)
    }
    
}

struct RecordingDictionary: Encodable {
    var exercise: String
    var startTimestamp: TimeInterval
    var sensorData: [SensorData]
}

import UniformTypeIdentifiers

class File: FileDocument {
    static var readableContentTypes: [UTType] {
        [.json]
    }
    
    // Stores the property's value as binary data adjacent to the model storage.
    @Attribute(.externalStorage)
    var file: Data
    
    var fileName: String

    init(fileName: String, file: NSData) {
        self.file = file as Data
        self.fileName = fileName
    }

    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            file = data
        } else {
            file = Data()
        }
        fileName = "NoFileName"
    }
    
    func fileWrapper(configuration: FileDocumentWriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: file as Data)
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

func generateJson(dataSource: DataSource, recording: RecordingData, fileName: String) -> File? {
    do {
        let descriptor = FetchDescriptor<SensorData>(
            predicate: #Predicate<SensorData> {
                $0.recordingStart == recording.startTimestamp
            }
        )

        guard let sensorData = try? dataSource.getModelContext().fetch(descriptor) else {
            throw RecordingExportError("Error CMBatchedSensorManager not supported")
        }

        let dict: RecordingDictionary = RecordingDictionary(
            exercise: recording.exercise,
            startTimestamp: recording.startTimestamp.timeIntervalSince1970,
            // todo we could remove the recordingStart from the sensorData
            sensorData: sensorData
        )
        
        let json = try JSONEncoder().encode(dict)
        
        let file = File(fileName: fileName, file: json as NSData)
        return file
    } catch {
        Logger.viewCycle.error("Failed to generate Json \(error.localizedDescription)")
        return nil
    }
}
