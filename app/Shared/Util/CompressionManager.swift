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
        print ("original data size: \(nsData.count) bytes")

        let compressedData = try nsData.compressed(using: .lzma)

        print("zlib compressed size: \(compressedData.count) bytes")
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
