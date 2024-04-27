//
//  vt1
//
//  Created by Julian Visser on 24.04.2024.
//

import Foundation

import SwiftData
import UniformTypeIdentifiers
import SwiftUI

@Model
class CompressedData: FileDocument {
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
        let decompressedData = try (file as NSData).decompressed(using: .zlib)
        return FileWrapper(regularFileWithContents: decompressedData as Data)
    }
}
