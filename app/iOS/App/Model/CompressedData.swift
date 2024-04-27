//
//  vt1
//
//  Created by Julian Visser on 24.04.2024.
//

import Foundation

import SwiftData

@Model
class CompressedData {
    
    // Stores the property's value as binary data adjacent to the model storage.
    @Attribute(.externalStorage)
    var file: Data
    
    var fileName: String

    init(fileName: String, file: NSData) {
        self.file = file as Data
        self.fileName = fileName
    }
}
