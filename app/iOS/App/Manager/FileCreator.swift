//
//  File.swift
//  vt1
//
//  Created by Julian Visser on 22.06.2024.
//

import Foundation
import UniformTypeIdentifiers
import SwiftUI

struct FileCreator {
    
    func generateJson(fileName: String, data: Encodable) async throws -> File? {
        let json = try JSONEncoder().encode(data)
        
        let file = File(fileName: fileName, file: json as NSData)
        return file
    }
}

class File: FileDocument {
    static var readableContentTypes: [UTType] {
        [.json]
    }
    
    // Stores the property's value as binary data adjacent to the model storage.
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
