//
//  CompressionManager.swift
//  vt1
//
//  Created by Julian Visser on 24.04.2024.
//

import Foundation

class CompressionManager {
    func compressData(_ data: Data) throws -> NSData{
        // todo catch error
        let nsData = data as NSData
        let compressedData = try nsData.compressed(using: .lzma)
        return compressedData
    }
}


struct CompressionError: LocalizedError {
    let description: String

    init(_ description: String) {
        self.description = description
    }

    var errorDescription: String? {
        description
    }
}
